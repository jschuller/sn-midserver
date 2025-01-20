#!/bin/bash
set -e

# Gather the names of the env variables defined in Dockerfile that are used to update the MID configuration
mid_env_names=("MID_INSTANCE_URL" "MID_INSTANCE_USERNAME" "MID_INSTANCE_PASSWORD" "MID_SERVER_NAME" \
               "MID_PROXY_HOST" "MID_PROXY_PORT" "MID_PROXY_USERNAME" "MID_PROXY_PASSWORD" \
               "MID_SECRETS_FILE" "MID_MUTUAL_AUTH_PEM_FILE" "MID_SSL_BOOTSTRAP_CERT_REVOCATION_CHECK" "MID_SSL_USE_INSTANCE_SECURITY_POLICY")

# Find the names of all other env variables that begin with MID_CONFIG_ or MID_WRAPPER_
regex="^(MID_CONFIG_[^=]+|MID_WRAPPER_[^=]+)=(.*)"
for var in $(printenv)
do
  if [[ $var =~ $regex ]]
  then
    mid_env_names+=(${BASH_REMATCH[1]})
  fi
done

# Sort the env names alphabetically
IFS=$'\n' sorted_mid_env_names=($(sort <<<"${mid_env_names[*]}"))
unset IFS

# Concatenate all MID env variables separated by |
all_mid_env_as_str=""
for val in "${sorted_mid_env_names[@]}"
do
  all_mid_env_as_str+="${val}=${!val}|"
done

echo "$all_mid_env_as_str" | md5sum
