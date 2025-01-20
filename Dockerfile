# ########################################################################################################################
# 1st Stage:
#     - Download the MID installation ZIP file, verify the digital signature and unzip the ZIP file to the base directory
#     - Copy the required scripts and other files from the recipe asset folder to the base directory
#     - Set the group's file permissions to match the owner's file permissions for the entire base directory
# ########################################################################################################################

FROM --platform=linux/amd64 eclipse-temurin:8-jdk-alpine AS pre_installation

RUN apk -q update && \
    apk add -q bash && \
    apk add -q wget && \
    rm -rf /tmp/*

ARG MID_INSTALLATION_URL=https://install.service-now.com/glide/distribution/builds/package/app-signed/mid/2025/01/07/mid.xanadu-07-02-2024__patch4a-12-16-2024_01-07-2025_0947.linux.x86-64.zip
ARG MID_INSTALLATION_FILE=""
ARG MID_SIGNATURE_VERIFICATION="TRUE"

WORKDIR /opt/snc_mid_server/

COPY asset/* /opt/snc_mid_server/

# download.sh and validate_signature.sh
RUN chmod 750 /opt/snc_mid_server/*.sh

RUN echo "Check MID installer URL: ${MID_INSTALLATION_URL} or Local installer: ${MID_INSTALLATION_FILE}"

# Download the installation ZIP file or using the local one
RUN if [ -z "$MID_INSTALLATION_FILE" ] ; \
    then /opt/snc_mid_server/download.sh $MID_INSTALLATION_URL ; \
    else echo "Use local file: $MID_INSTALLATION_FILE" && ls -alF /opt/snc_mid_server/ && mv /opt/snc_mid_server/$MID_INSTALLATION_FILE /tmp/mid.zip ; fi

# Verify mid.zip signature
RUN if [ "$MID_SIGNATURE_VERIFICATION" = "TRUE" ] || [ "$MID_SIGNATURE_VERIFICATION" = "true" ] ; \
    then echo "Verify the signature of the installation file" && /opt/snc_mid_server/validate_signature.sh /tmp/mid.zip; \
    else echo "Skip signature validation of the installation file "; fi

# Clean up and extract mid installation zip file to /opt/snc_mid_server/
RUN rm /opt/snc_mid_server/* && unzip -d /opt/snc_mid_server/ /tmp/mid.zip && rm -f /tmp/mid.zip

# Copy only required scripts and .container
COPY asset/init asset/.container asset/check_health.sh asset/post_start.sh asset/pre_stop.sh asset/calculate_mid_env_hash.sh /opt/snc_mid_server/

# Give the owner group the same permissions as the owner user.
# Running this command in this stage reduces the final image size.
RUN chmod -R g=u /opt/snc_mid_server

# ########################################################################################################################
# Final Stage:
#     - Install the base OS security and bugfix updates
#     - Install the packages required by the MID Server application
#     - Add the mid user and group
#     - Copy application files from the previous stage
#     - Grant the execution permission for the scripts and binaries that do not have it
# ########################################################################################################################

FROM --platform=linux/amd64 almalinux:9.2

# Install security and bugfix updates, and then the required packages.
RUN dnf update -y --security --bugfix && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf install -y --allowerasing glibc-langpack-en \
                    bind-utils \
                    xmlstarlet \
                    curl \
                    procps-ng \
                    diffutils \
                    net-tools && \
    dnf clean all -y && \
    rm -rf /tmp/*

ARG MID_USERNAME=mid
ARG GROUP_ID=1001
ARG USER_ID=1001

# Env Variables
ENV MID_INSTANCE_URL="" \
    MID_INSTANCE_USERNAME="" \
    MID_INSTANCE_PASSWORD="" \
    MID_SERVER_NAME="" \
    # Ensure UTF-8 Encoding
    LANG="en_US.UTF-8" \
    # Optional Env Var
    MID_PROXY_HOST="" \
    MID_PROXY_PORT="" \
    MID_PROXY_USERNAME="" \
    MID_PROXY_PASSWORD="" \
    MID_SECRETS_FILE="" \
    MID_MUTUAL_AUTH_PEM_FILE="" \
    MID_SSL_BOOTSTRAP_CERT_REVOCATION_CHECK="" \
    MID_SSL_USE_INSTANCE_SECURITY_POLICY=""

# Add the mid user and group
RUN if [[ -z "${GROUP_ID}" ]]; then GROUP_ID=1001; fi && \
	if [[ -z "${USER_ID}" ]]; then USER_ID=1001; fi && \
    echo "Add GROUP id: ${GROUP_ID}, USER id: ${USER_ID} for username: ${MID_USERNAME}" && \
    groupadd -g $GROUP_ID $MID_USERNAME && \
    useradd -c "MID container user" --shell /sbin/nologin -r -m -u $USER_ID -g $MID_USERNAME $MID_USERNAME

# Copy files from previous stage and make them owned by the mid user and the root group.
COPY --chown=$USER_ID:0 --from=pre_installation /opt/snc_mid_server /opt/snc_mid_server

# When containers run as the root user, file permissions are ignored, but for rootless containers, 
# the permission bit is required in order to execute files.
RUN chmod 770 /opt/snc_mid_server && chmod 770 /opt/snc_mid_server/init && \
    chmod 770 /opt/snc_mid_server/*.sh && \
    chmod 770 /opt/snc_mid_server/agent/bin/wrapper-linux*

# Check if the wrapper PID file exists and a HeartBeat is processed in the last 30 minutes
HEALTHCHECK --interval=5m --start-period=3m --retries=3 --timeout=15s \
    CMD bash check_health.sh || exit 1

WORKDIR /opt/snc_mid_server/

USER $MID_USERNAME

ENTRYPOINT ["/opt/snc_mid_server/init", "start"]