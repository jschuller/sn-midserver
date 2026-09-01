<!-- Source: servicenow.com/docs | Map: 8K~WUyyBmjUR0pLPxM8yeA | Harvested: 2026-08-31 -->
# Containerized MID Server


## Containerized MID Server

# Containerized MID Server

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 4 min.  de leituraContainerized MID Server uses a Docker image of the MID Server that allows you to
      quickly deploy MID Servers at scale. MID Servers are deployed using orchestration tools like
      OpenShift or Kubernetes. Orchestration tools can automate their deployment and maintenance and
      add new containers on demand or replace failed containers automatically.

      
                  
                     
                  
               
      To use Containerized MID Servers, you can download Docker recipes for Linux from the MID
         Server download page. Use the recipes to build the Docker images for the current release.
         The recipes are zipped and signed. Some features have been deprecated for the Washington DC
         family release. See [KB1559617] Deprecated Containerized MID Server Features
            in Washington DC for more information.

      Containerized MID Server system requirements:
            AlmaLinux is supported.

            The recipes cannot be used to build images for previous MID Server versions.

            Discovery of NMAP and CyberArk are not supported.

            Other applications such as Orchestration and Integration Hub are not certified.

         
      Once the Docker images are available, you can create new MID Server containers and configure them with configuration parameters passed through environment variables or secret files. Docker, Openshift, and Kubernetes secrets are
         supported. The MID Server application inside the container is run as a process by a non-admin user.

      When a containerized MID Server record is first created on the instance, a random UUID is
   created and set to the container_id column. During the start-up sequence,
   this value is replaced by the actual container ID. The container ID can be used to differentiate
   between containerized and regular MID Servers. Non-containerized MID Servers' container ID have a
   null or empty value.

      In order to automatically clean up the down MID Servers on Instance, a scheduled job called
   Purge Orphaned Containerized MID Servers is scheduled to run daily. This job removes orphaned
   containerized MID Servers if they are down longer than the value set by the
    max_retention_days property. The job also creates a warning MID Server
   issue each day before the removal day, if there are equal to or less than the value of
    warn_days remaining. The default values for
    max_retention_days and warn_days are 30 and 7,
   respectively.

      ## Auto-upgrade

         
         Auto-upgrade works the same way for containerized MID Servers as it does for regular MID Servers. However, it is recommended to disable the auto-upgrade for containerized MID Servers. Whenever a new image is needed, build a new
            image and deploy it by updating the deployment YAML file then re-apply it.

         Containerized MID Server auto-upgrade is controlled by the
               mid.container.autoupgrade.enabled config parameter and is set
            to true by default. The config parameter is read-only, therefore it can not be synced
            down from the instance.

         Add the config parameter to a MID Server profile and use it with new deployment requests. The settings are then included in deployment YAML file when the deployment request is exported, or when it is manually added to an
            existing deployment YAML file and re-applied.

      
      ## HealthCheck

         
         A HEALTHCHECK rule is implemented to check MID Server health status based on heartbeat every 5
    minutes. If there was no heartbeat activity in last 30 minutes, it is considered a failure.
    After 3 consecutive failures, it becomes unhealthy in the docker ps command output.

         To see more HealthCheck details, run the following docker inspection command: docker inspect --format='{{json
     .State.Health}}' <container-id> 

      
      ## Basic Container Operations

         
         Basic operations are supported on container side. For example, you can stop, start, or restart
    a running container using Docker commands.
               
                  docker stop <container_id>
                  This command shuts down the containerized MID Server.
               
               
                  docker start <container_id>
                  This command starts a containerized MID Server if it is stopped.
               
               
                  docker restart <container_id>
                  This command shuts down a MID Server and restarts it.
               
            
      
      ## Build MID Server Docker Image

         
         Build a MID Server Docker Image with the provided recipes to deploy a Containerized MID Server. Containerized MID Server uses a Docker image of the MID Server that allows you to quickly
            deploy MID Servers at scale.

      
      ## Containerized MID Server Deployment and Auto-configuration

         
         With the deployment and auto-configuration
     feature, an agent admin can enter all required MID Server  settings in a MID Server
    Profile on the instance and then submit a deployment request to K8s cluster. After the request
    is  processed, the new MID servers are automatically created and auto-configured. They are
    ready  to use in seconds.  If the MID Server profile is changed, the related Containerized MID
    Servers can also be updated on demand.

---


### Build MID Server Docker Image for Linux

# Build MID Server Docker Image for Linux

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 11 min.  de leituraDeploy Containerized MID Servers on Linux by creating a Docker image with the
        provided recipes. Containerized MID Server uses a Docker image of the MID Server that allows
        you to quickly deploy MID Servers at scale.

      ## Antes de Iniciar

         Role required: admin

         
                  
                     
                  
               
         Prerequisites:

         The host must use Docker engine and command-line interface (CLI) 20.10.4
               or later.

         Update the library to the newest version available, or at least the highest version with
            a security fix. If issues identified are part of a transitive dependency, find a version
            of the dependent library which includes a newer transitive version. If the transitive
            dependency cannot be upgraded by upgrading the dependent library, consider excluding the
            dependency and directly including a secure version.

         Nota: Check docker availability by running the docker version command
            as administrator. See the the docker version command documentation for more
            information.
      
      ## Procedimento

            Download the Linux Docker recipe ZIP file from the MID Server download page and
                    verify its signature.
            For more information about the MID Server download page and signature
                    verification, see Download MID Server files.
         
            Unzip the ZIP file to a folder.
         Opcional: 
            You can change the current directory to the new folder.
         
            To build an image, run the build command:  > docker build
                        <path-to-docker-recipe> [ --tag <docker-tag> ]
            
               For more information on the command, see the Docker build command
                            documentation.  The path to the Docker file can be a relative
                        path or the current directory if the file is in the Docker recipe directory.

               The default image tag is provided out-of-the box in the .env file with the
                            DOCKER_TAG parameter. You can export this
                        parameter before executing any docker command by running the command:
                            > export $(grep DOCKER_TAG .env). You can replace
                            <docker-tag> with the
                            DOCKER_TAG value in all the following commands.

               The build command takes the following build arguments:

               
                     
                        Property
                        Description
                     
                  
                     
                        MID_INSTALLATION_URL
                        The link to download the MID Server installation file. By
                  default, it is set to the download link for the Linux 64 bit Installation ZIP file
                  provided on the MID Server download page.
                     
                     
                        MID_INSTALLATION_FILE
                        The name of a local MID Server installation file. The default
                  value is empty. If this parameter is not empty, the recipe uses the local file
                  instead of downloading from the installation server. This parameter uses the file
                  name only, not the full path. Before the build, the local file must be copied to
                  the asset/ sub-folder of the recipe directory. MID Server releases prior to Rome are not
                    supported.For example: > docker build <path-to-dockerfile>
                      --build-arg MID_INSTALLATION_FILE=<mid.installation.file.name>) --tag
                      <docker-tag>

                     
                     
                        MID_SIGNATURE_VERIFICATION
                        The signature of the MID Server installation file must be
                  verified. The default value is TRUE. If it is TRUE, the build process always
                  verifies the digital signature of the MID Server installation file
                  whether it is downloaded from the remote server or a local file. Otherwise, the
                  signature verification is skipped.For example: > docker build
                      <path-to-dockerfile> --build-arg MID_SIGNATURE_VERIFICATION=false --tag
                      <docker-tag>

                     
                     
                        USER_ID and GROUP_ID
                        By default, when not specified, Docker creates a   MID Server user with user id = 1001 and group id = 1001. You may pass a custom user id and group id into container by using the USER_ID and GROUP_ID build arguments. Docker creates an user for
                              the  MID Server  with the provided user id and group id. Inside the container image, all files under the MID Server installation folder are owned by this user and the root group (id=0).

                           When the image is deployed on Kubernetes platform, this MID Server user becomes the container user who runs
                              the MID Server.

                           When the image is deployed on an OpenShift platform, OpenShift may
                              assign an arbitrary non-admin user id as the container user who runs
                              the MID Server. However, that user always belongs
                              to the root group.

                           In both cases, the container user has full access to the MID Server files. That way, the same image can be
                              deployed on Kubernetes as well as on OpenShift.

                     
                  
            
         Opcional: 
            After the image is built successfully, you can list the image built with
                    command: > docker image ls
         
      ## O que Fazer Depois

         To save disk space, if there are unused or intermediate images, run the following
                commands to remove those dangling images:
                $ docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
         For example, before removing dangling images, the command docker image
                    ls may show something similar to the
                following:REPOSITORY                                TAG                                           IMAGE ID       CREATED              SIZE
mid                                       trackdiscocopper-10-09-2020_10-14-2021_2200   4542b6ab34af   21 seconds ago       1.01GB
<none>                                    <none>                                        1cdae087a970   About a minute ago   1.38GB

         After removing the dangling images, the command docker image ls
                shows the
                following:REPOSITORY                                TAG                                           IMAGE ID       CREATED              SIZE
mid                                       trackdiscocopper-10-09-2020_10-14-2021_2200   4542b6ab34af   About a minute ago   1.01GB

      
   

   ## Launch Containerized MID Server

   
   
   Containerized MID Server uses a Docker image of the MID Server that allows you to
      quickly deploy MID Servers at scale. MID Servers are deployed using orchestration tools like
      Docker Swarm.

      ### Antes de Iniciar

         Role required: admin

         Prerequisites:

         
            Linux hosts must use AlmaLinux distribution 64 bit architecture, and AlmaLinux
                  distro is recommended.

            The host must use Docker engine and command-line interface
                            (CLI) 20.10.4 or later.

               Nota: Check docker availability by running the docker version command as
                        administrator. See the the docker version command
                            documentation for more information.
         
      
      ### Procedimento

            Once the image is available, launch the new MID Server using the docker run
                    command and specify an env file or env variable options: docker run
                        --env-file <env_file_name_here> <docker_tag or
                    image_id>
            
               Nota: Do not pass sensitive data using this command, as there may be security
                        vulnerabilities. To pass sensitive data, use the procedures Pass sensitive data to a containerized MID Server with Docker Secrets and Pass sensitive data to a containerized MID Server with Kubernetes Secrets.
               For more information, see the Docker documentation pages for the docker image ls command, the docker run command, and specifying an env file or env variable
                            options. The env file is a simple text file using the name=value
                        format. If a variable is specified in both env file and in the
                            --env option, the variable defined in the command
                        line takes precedence.

               While deployment requests are the recommended method to launch containerized MID
                  Servers, they can be alternatively configured with environmental variables. When
                  the container is first started, the initialization script will take the
                  environment variables and configure the MID Server application using the following
                  environment variables:
                     
                        MID_INSTANCE_URL
                        This variable sets the ‘url’ config parameter.
                     
                     
                        MID_INSTANCE_USERNAME
                        This variable sets the ‘mid.instance.username’ config parameter.
                     
                     
                        MID_INSTANCE_PASSWORD
                        This variable sets the ‘mid.instance.password’ config parameter.
                     
                     
                        MID_SERVER_NAME
                        This variable sets the ‘name’ config parameter.
                     
                     
                        MID_PROXY_HOST
                        This variable sets the ‘mid.proxy.host’ config parameter. This variable
                           is not mandatory and is only necessary when a proxy is set up.
                     
                     
                        MID_PROXY_PORT
                        This variable sets the ‘mid.proxy.port’ config parameter.
                     
                     
                        MID_PROXY_USERNAME
                        This variable sets the ‘mid.proxy.username’ config parameter.
                     
                     
                        MID_PROXY_PASSWORD
                        This variable sets the ‘mid.proxy.password’ config parameter.
                     
                     
                        MID_SECRETS_FILE
                        This variable specifies the full secret filename that contains sensitive
                           data like passwords or certificate.
                     
                     
                        MID_MUTUAL_AUTH_PEM_FILE
                        This variable specifies the full filename of the client certificate file
                           used for auto validation setup.
                     
                  
            
         Opcional: 
            To see a list of containers, run the docker container ls command:
                        docker container ls [-a]
         
   

   ## Pass sensitive data to a containerized MID Server with Docker Secrets

   
   
   You can configure containerized MID Servers with configuration parameters passed
        through environment variables or secret files.

      ### Antes de Iniciar

         Role required: Docker Swarm admin

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         You can pass sensitive data, such passwords or certificates, into a containerized MID
                Server using Docker Secret. Setup and start Docker Swarm before using this procedure.

         When creating deployments, ensure that the replicas are kept to 1.

      
      ### Procedimento

            Place the sensitive data in mid-secrets.properties
         
            Create a docker secret using the docker secret create command: docker
                        secret create mid-secrets mid-secrets.properties
            
               The first mid-secrets represents the secret in docker
                        swarm, while the second mid-secrets.properties
                        parameter represents the file path to read the secret on the host machine’s
                        filesystem. You can list all created secrets by running the command
                            docker secret ls.

               For more information on the docker secret command, see the docker secret
                        documentation.

            
         
            Update the MID_SECRETS_FILE environment variable with
                    the path to the secret file inside the container.
            The default path for Docker Swarm secrets on Linux is /run/secrets/mid-secrets.properties.
         
            Deploy the MID Server Image Container to Swarm using the docker service create
                    command: docker service create --name mid-service --secret
                        mid-secrets.properties --env-file mid.env <docker-tag or
                        image-id>
            
               Make sure that the --secret flag is provided for the
                        container service to associate with the specified secrets.

            
         
   

   Pass sensitive data to a mutual authenticated containerized MID Server with Docker
        Secrets
   
   
   You can configure containerized MID Servers with configuration parameters passed
        through environment variables or secret files.

      ### Antes de Iniciar

         Role required: admin

         Role required: Docker Swarm admin

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         If
                    certificate based
                    authentication is enabled on the
                instance,
                the MID Server can be configured to auto-validate using a mutual authentication
                    client certificate (PEM file). This can be done via setting the full path
                to the PEM certificate file inside container with the
                    MID_MUTUAL_AUTH_PEM_FILE environment variable. For example,
                you can update variable to MID_MUTUAL_AUTH_PEM_FILE=
                    /run/secrets/certificate.pem in the mid.env
                file.

         You can pass the PEM certificate file into a container using Docker or
                Kubernetes
                secret. The following is an example command to pass the PEM certificate file into a
                container: docker service create --name mid-service --secret
                    mid-secrets.properties --secret <certificate-secret-name> --env-file mid.env
                    <docker-tag or image-id>

         The mutual PEM certificate is installed on the MID Server during initialization. MID
                Server then connects to the instance and auto-validates. When the MID Server
                connects to the instance with mutual authentication successfully enabled, you
                might
                observe some of the following entries in the MID agent log:

         
            Installed custom certificate into the MID keystore
            Configured MID to use mutual authentication
         
      
      ### Procedimento

            Prepare the mutual authentication PEM bundle.
         
            Create a docker secret using the docker secret create command: docker
                        secret create mutual-auth-secret
                        <mutual-auth-pem-file-on-local-filesystem> .
            
               You can list all created secrets by running the command docker secret
                            ls.

            
         
            Update the MID_MUTUAL_AUTH_PEM_FILE environment variable
                    with the path to the secret file inside the container.
            
               The default path for Docker Swarm secrets on Linux is /run/secrets/<mutual-auth-pem-file-name>.

            
         
            Deploy the MID Server Image Container to Swarm using the docker service create
                    command: docker service create --name mid-service --secret
                        mutual-auth-secret --env-file mid.env <docker-tag or
                    image-id>
            
               Ensure the --secret flag is provided for the container
                        service to associate with the specified secrets.

            
         
            Deploy the containerized MID Server to the pod with the
                        deployment.yml and run the command: kubectl
                        create -f deployment.yml
         
   

   ## Pass sensitive data to a containerized MID Server with Kubernetes Secrets

   
   
   You can configure containerized MID Servers with configuration parameters passed
        through environment variables or secret files.

      ### Antes de Iniciar

         Role required: Kubernetest admin

         Setup and start Kubernertes cluster before using this procedure. For
                more information on Kubernetes Secrets, see the Kubernertes secrets documentation.

         Nota: Kubernetes doesn’t work directly with a local image. Upload the MID Server image
                to a public registry or setup a local registry. See the
                    official Docker instruction on building a docker registry.
         When creating deployments, ensure that the replicas are kept to 1.

      
      ### Procedimento

            Place the sensitive data in mid-secrets.properties accordingly.
         
            Create a Kubernetes secret with the command: kubectl create secret
                        generic mid-secret --from-file=mid-secrets.properties
         Opcional: 
            You can list all created secrets by running the command: kubectl get
                        secrets
         
            Update the MID_SECRETS_FILE environment variable with
                    the path to the secret file inside container.
            The path is defined in data field when creating a configuration file
                        for a Secret.
         
            Create a deployment with the following sample YML content:
            
               apiVersion: apps/v1
kind: Deployment
metadata:
  name: basic-example
spec:
  selector:
    matchLabels:
      app: MIDServerManagement
      provider: ServiceNow
  replicas: 1
  template:
    metadata:
      labels:
        app: MIDServerManagement
        provider: ServiceNow
    spec:
      containers:
        - name: basic-example-container
          imagePullPolicy: IfNotPresent
          image: "mid:imageTag"
          env:
            - name: MID_INSTANCE_URL
              value: " https://exampleinstance.service-now.com/"
            - name: MID_INSTANCE_USERNAME
              value: "mid_server_user_name”
            - name: MID_SECRETS_FILE
              value: "/opt/snc_mid_server/secrets/mid-secrets.properties“
            - name: MID_SERVER_NAME
              value: "Basic-Example-MID"
          volumeMounts:
            - mountPath: "/opt/snc_mid_server/secrets"
              name: "mid-mount-secret"
              readOnly: true
      volumes:
      - name: "mid-mount-secret"
        secret:
          secretName: "mid-secret"

               Nota: There are many ways to create a deployment or pod. For more information,
                        see the Kubernetes deployment
                        instructions.  
            
         
            Deploy the containerized MID Server to the pod with the deployment.yml and run
                    the command: kubectl create -f deployment.yml
         
   

   Pass sensitive data to a mutual authenticated containerized MID Server with Kubernetes
        Secrets
   
   
   You can configure containerized MID Servers with configuration parameters passed
        through environment variables or secret files.

      ### Antes de Iniciar

         Role required: Kubernetest admin

         Prerequisites:

         If
                    certificate based
                    authentication is enabled on the
                instance,
                the MID Server can be configured to auto-validate using a mutual authentication
                    client certificate (PEM file). This can be done via setting the full path
                to the PEM certificate file inside container with the
                    MID_MUTUAL_AUTH_PEM_FILE environment variable. You can pass
                the PEM certificate file into a container using
                Kubernetes
                secret.

         The mutual PEM certificate is installed on the MID Server during initialization. MID
                Server then connects to the instance and auto-validates. When the MID Server
                connects to the instance with mutual authentication successfully enabled, you
                might
                observe some of the following entries in the MID agent log:

         
            Installed custom certificate into the MID keystore
            Configured MID to use mutual authentication
         
      
      ### Procedimento

            Prepare the mutual authentication PEM bundle.
         
            Create a Kubernetes secret with the command: kubectl create secret
                        generic mutual-auth-secret
                    --from-file=<mutual-auth-pem-file>
         Opcional: 
            You can check all created secrets by running the command: kubectl get
                        secrets
         
            Update the MID_MUTUAL_AUTH_PEM_FILE environment variable
                    with the path to the secret file inside container.
         
            Create a deployment with the following sample YML content:
            
               6.	apiVersion: apps/v1
7.	kind: Deployment
8.	metadata:
9.	  name: mutual-auth-example
10.	spec:
11.	  selector:
12.	    matchLabels:
13.	      app: MIDServerManagement
14.	      provider: ServiceNow
15.	  replicas: 1
16.	  template:
17.	    metadata:
18.	      labels:
19.	        app: MIDServerManagement
20.	        provider: ServiceNow
21.	    spec:
22.	      containers:
23.	        - name: mutual-auth -container
24.	          imagePullPolicy: IfNotPresent
25.	          image: "mid:imageTag”
26.	          env:
27.	            - name: MID_INSTANCE_URL
28.	              value: "https://exampleinstance.service-now.com/"
29.	            - name: MID_INSTANCE_USERNAME
30.	              value: "mid_server_user_name”
31.	            - name: MID_SERVER_NAME
32.	              value: "Mutual-Auth-Deployment-MID"
33.	            - name: MID_MUTUAL_AUTH_PEM_FILE
34.	              value: "/opt/snc_mid_server/mutual-auth/yourpemfile.pem"
35.	          volumeMounts:
36.	            - mountPath: "/opt/snc_mid_server/mutual-auth"
37.	              name: "mid-mount-mutual-auth"
38.	              readOnly: true
39.	      volumes:
40.	      - name: "mid-mount-mutual-auth"
41.	        secret:
42.	          secretName: "mid-mutual-auth-secret"

            
         
            Deploy the containerized MID Server to the pod with the
                        deployment.yml and run the command: kubectl
                        create -f deployment.yml

---


### Containerized MID Server Deployment and Auto-configuration

# Containerized MID Server Deployment and Auto-configuration

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 4 min.  de leituraAn agent admin can enter a MID Server Profile and create a deployment request on the
      instance. She/he can then export the deployment request to a YAML file and use it to deploy
      MID Servers to Kubernetes or OpenShift cluster.

      
                  
                     
                  
               
      
         Containerized MID Servers use a Docker image of the MID Server that allows you to quickly deploy MID Servers. The documentation for Build MID Server Docker Image for Linux provides steps for manually preparation and deployment. The following Containerized MID Server auto-configuration simplifies the process and makes it scalable.

      
      ## MID Server profile

         
         
         A MID Server profile contains all the settings required to configure a new MID Server,
    excluding sensitive data such as passwords and certificates. Sensitive data should be passed
    through Secrets created on the K8s cluster. The user only enters secret names and locations in
    the deployment request. An agent_admin role is required to create or
    change profiles. MID Server profiles are stored in the following tables:
               mid_server_profile
               mid_profile_config
               mid_profile_wrapper_config
               mid_profile_property
               mid_profile_application_m2m
               mid_profile_capability_m2m
               mid_profile_ip_range_m2m
               mid_profile_cluster_m2m
            
         During deployment, the mid_profile_config and
     mid_profile_wrapper_config parameters are sent to the K8s cluster. These
    parameters populate the config.xml and wrapper-override.conf
    of the new MID Server. The other parameters are used by the auto-configuration on the instance.
    The user can access the MID Server profile from the module MID Server
     Profiles on the instance.

         The MID Server name is not required in a profile because a profile can be used to deploy
    multiple MID Servers. Instead, the user is asked to enter MID Server names as part of a new
    deployment request. For the mid_profile_wrapper_config, the user can
    enter any parameters that they want to see in wrapper-override.conf. For
    example:

         
                  
                     Name
                     Value
                  
                  
                     wrapper.java.maxmemory
                     2048
                  
                  
                     wrapper.java.additional.3
                     -Djavax.net.debug=ssl:handshake
                  
               
         Other profile settings can be entered the same way as on a MID Server record.

      
      ## MID Server Deployment Request

         
         After creating a MID server profile, the user can make a new deployment request to prepare the
    deployment process.​ A deployment request can be different for different container
    orchestrators. See MID Server Deployment Request for more
    information.

      
      ## Export MID Deployment Request for Manual Deployment

         
         The user can export it to a K8s deployment YAML file. The user can download the YAML
            file to the K8s cluster and deploy new MID Servers with the following command:
               kubectl apply –f <yaml_file>

      
      ## Docker image preparation

         
         To prepare a Docker image, first build a MID Server image on a K8s cluster as explained in Build MID Server Docker Image. Upload the built image to an image registry and pull the image to a local image with the command: docker pull registry/mid:<tag>. Refer
        to Docker Registry Setup for Containerized MID Server II: Auto Configuration [KB1001380] for information on limitations on pulling an image directly from a remote registry.

      
      ## Kubernetes preparation

         
         See also How to build and deploy Containerized MID Servers in
               Kubernetes using StatefulSets [KB1325173].

         
            Kubernetes service account setup
         
         Ensure the service account has the proper RBAC set up to create, delete, and list permission
        for resources. The following example YAML file uses the default service
        account:apiVersion: rbac.authorization.k8s.io/v1 
 kind: ClusterRoleBinding 
 metadata:   
    name: default-service-acccount-as-cluster-admin 
 subjects:   

  - kind: ServiceAccount 
    # Reference to upper's `metadata.name`     
    name: default 
    # Reference to upper's `metadata.namespace`     
    namespace: default 
 roleRef:   
    kind: ClusterRole 
    name: cluster-admin 
    apiGroup: rbac.authorization.k8s.io
         You may choose a custom service account and assign a ClusterRole to
    that service account and name space. The default name space is default.
    The following example YAML file uses a custom name space,
    mynamespace.

         apiVersion: rbac.authorization.k8s.io/v1 
 kind: ClusterRoleBinding 
 metadata:   
    name: custom-serviceacccount-as-cluster-admin 
 subjects:   

  - kind: ServiceAccount 
    # Reference to upper's `metadata.name`     
    name: mycustomserviceaccount 
    # Reference to upper's `metadata.namespace`     
    namespace: mynamespace 
 roleRef:   
    kind: ClusterRole 
    name: cluster-admin 
    apiGroup: rbac.authorization.k8s.io
         
            Kubernetes Secret setup
         
         Secrets are created for mid-secrets.properties or PEM files for mutual
    authentication. For more information about how to create a Secret, see the section in Containerized MID Server.

      
      ## Auto-configure new Containerized MID Servers

         
         When a MID server is connected to the instance for the first time, a MID Server record is
    created. The MID Server record is populated with the container ID, profile ID and deployment
    name. The Auto-Configure MID from profile business rule is triggered when
    the new MID Server record is updated with a profile ID in the profile_id
    field. The business rule looks up the profile settings associated with that profile ID and
    configures the new MID server accordingly.

      
      ## Sync MID Server Profile to existing MID Servers

         
         The MID Server profile can be out-of-sync with the settings of existing MID Servers if the
    user updates the profile long after the related MID Servers were auto-configured. The user can
    synchronize the profile settings to the existing MID Server by selecting Sync to MID
     Servers on the instance.

         Nota: When applying cluster settings from MID Server profile to a MID Server, the cluster assignment will fail if the MID Server doesn't have any capability assigned. It is controlled by the "validate MID server capability"
            business rule on the ecc_agent_cluster_member_m2m table. If you want to assign a MID server to a cluster, please make sure it has some capabilities.

---


#### MID Server Deployment Request

# MID Server Deployment Request

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 2 min.  de leituraAfter creating a MID server profile, the user can make a new deployment request to
        prepare the deployment process.​ A deployment request can be different for different
        container orchestrators.

      ## Antes de Iniciar

         Role required: agent_admin

         
                  
                     
                  
               
         
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         The user can access MID Server deployment request from the app module MID
               Deployment Requests.​

         Currently, only K8s deployment is supported. The K8s deployment request includes a
            reference to a MID Server profile, information about a MID Server docker image, K8s
            secrets, K8s deployment labels, and a list of MID Server names to assign to the new MID
            Servers.

      
      ## Procedimento

            Enter information about the container image.
            
               In this section, you will specify which image is used with this deployment
                        request and where it can be pulled from.

               
                  
                     Image Registry Path and Repository
                     Enter a registry address and port, as well as a repository name
                                    where the image is stored. The syntax is
                                        my.registry.address:port/repositoryname.

                  
                  
                     Image Tag
                     Enter a tag that identifies the container image.

                  
               
            
         
            Specify the MID Server names.
            
               A deployment request can be made to create multiple MID Servers. You can
                        choose to enter the MID Server names manually, otherwise the system
                        automatically generates them. If you enter the names manually, each MID
                        Server name must be unique.

            
         
            Enter the Kubernetes cluster Information.
            
               
                  
                     K8s Namespace
                     Enter a K8s namespace where the new MID servers are located. The
                                    default value is default.

                  
                  
                     K8s Service Account
                     Enter a K8s service account name that processes this deployment
                                    request. The default value is default.

                  
                  
                     MID Secrets Name
                     Enter the name of a K8s secrets object that holds MID Server
                                    secrets.

                  
                  
                     MID Secrets File Path
                     Enter the absolute path of the MID Server secrets file inside the
                                    container.

                  
                  
                     MID Mutual Auth PEM Secrets Name
                     Enter the name of a K8s secrets object that holds the MID Mutual
                                    Auth PEM certificate.

                  
                  
                     MID Mutual Auth PEM File Path
                     Enter the absolute path of the MID Mutual Auth PEM file inside
                                    container.

                  
                  
                     K8s Deployment Label
                     Enter a deployment label which is a list of key/value pairs. The
                                    label is attached to K8s deployment. A valid label must be 63
                                    characters or less and can be empty. Unless the label is empty,
                                    it must begin and end with an alphanumeric character and contain
                                    only dashes, underscores, dots, and alphanumeric characters.

                  
               
            
         
      ## O que Fazer Depois

         When a request is ready, the user can choose Export to YAML file to generate a K8s deployment YAML file and attach it to the same record.​ Once a request is processed, the entire record is set to
            read-only. There is a scheduled job that removes deployment requests older than 365 days.

---


### Containerized MID Server Autoscaling

# Containerized MID Server Autoscaling

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 2 min.  de leituraMID Servers can be deployed via StatefulSet with any number of replicas. They can scale
  automatically by leveraging Kubernetes Horizontal Pod Autoscaler (HPA). Horizontal Pod Autoscaler
  automatically updates a workload resource (such as a Deployment or StatefulSet) to match
  demand.

      
                  
                     
                  
               
      
         Kubernetes can add or remove any numbers of stateful MID Server replicas as required by the workload. HPA only supports CPU and memory metrics. MID Servers can be deployed as a stateful application by providing the following
            information in the StatefulSet section of the deployment request form:
               Name
               Headless service name
               Persistent volume claim (PVC)
               Parameters, such as storage class, access modes, and storage request
               The resource request/limit
            
         The PVC declares the desired persistent volume where the MID Server stores config.xml, meta
    data files, and several of its sub-folders.

         During workload fluctuations, a pod with a running MID Server container can be removed and
    replaced by a new one. StatefulSet ensures the same persistent volume is attached to the new
    pod, which allows the MID Server to resume its state.

         The only sub-folders that can be mounted to the persistent volume are those that are initially
    empty with a new MID Server installation. The config.xml file and other
    meta data files must be backed up when the pod is shut down and restored during start-up.

         Deployment requests exported as YAML files can be used to create a StatefulSet workload and
    new MID Server pods in the Kubernetes cluster.

         When you make changes to the deployment YAML file and re-apply it, the existing pods of the deployment are recreated. With StatefulSet deployment, the configuration files are restored from the backup folder. The init script must
            detect the deployment environment changes and apply them to the configuration files before MID server is started.

      
      ## HPA Autoscaling activation

         
         HPA Autoscaling can be activated for any existing StatefulSet workload by creating an HPA
    controller.

         When you create a deployment request, you can choose either HPA version 1 or version
            2.

         When creating a deployment request on the instance with an HPA configuration, apply the
            exported YAML file and HPA autoscaling begins working immediately.

---
