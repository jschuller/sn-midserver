<!-- Source: servicenow.com/docs | Map: 8K~WUyyBmjUR0pLPxM8yeA | Harvested: 2026-08-31 -->
# Installing the MID Server


## Installing the MID Server

# Installing the MID Server

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 1 min.  de leituraDownload and install the MID Server on the host machine, test the connection, and then
        validate the MID Server. Use the manual procedures or the guided setup. Set up multiple MID
        Servers for load balancing and domain separation. These procedures prepare it for use with
        any application.

      
                  
                     
                  
               
      Prerequisites: Ensure the MID Server system requirements and
                MID Server connection
                prerequisites are met before you install the MID Server manually or use the
            guided setup utility.

      ## MID Server manual installation

         
         The manual process requires these setup tasks, performed in the order shown here:
               Create
                            the MID Server user account and grant the appropriate role to
                        this user.
               Download the installer file for the host machine.
               Install the MID Server on a Linux or Windows host.
               Validate
                            the MID Server to ensure that it is trusted to access credentials
                        used by the instance for automations.
               Test connectivity between the MID Server and the instance for
                        automatic upgrades.
               Optionally, deploy multiple MID Servers in your network for load balancing
                        or when domain separation is enabled.
            
      
      ## MID Server guided setup

         
         Alternatively, the MID
                    Server Guided Setup streamlines the process and allows you to set up a
                basic MID Server quickly.

---


### Create the MID Server user and grant the role

# Create the MID Server user and grant the role

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 4 min.  de leituraTo communicate with the instance, MID Servers need a user ID and the appropriate role.
        Create the user ID for a MID Server and grant the ID the mid_server
        role. To prevent MID Server validation failure, the system runs business rules to monitor
        the settings selected for MID Server users.

      ## Antes de Iniciar
Role required: admin
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         The MID Server connects to an instance by using the SOAP web service. To allow authentication with the instance, create a separate user account for each MID Server or share the same account across multiple
            MID Servers. Grant each MID Server user the mid_server role, which is required for the MID Server user on any instance on which basic authentication is enabled. The mid_server role allows the MID Server to access protected
            tables when strict SOAP security is in place. The system adds the necessary SOAP roles automatically with this role.
         Nota: The strict SOAP security feature, enabled by default for any instance that uses basic authentication, protects all tables with Access Control Lists (ACL).
         If multiple MID Servers are using the same logged in user, an issue record is created when more than one is Up at a time. It is recommended that MID Servers use a unique logged in user. See (KB1552863) MID Server Unique Logged In User for more information and remediation steps.

      ## Procedimento

            From the instance, navigate to User Administration > Users.
         
            Click New.
         
            Complete the fields in the form.
            
               
                        
                           Field
                           Description
                        
                     
                        
                           User ID
                           User name for the MID Server user. This name is specified in the mid.instance.username parameter of the configuration file that the MID Server installer creates. For details, see MID Server parameters.

                              Nota: Avoid using the same MID Server logged in user across multiple MID Servers.
                        
                        
                           First name
                           The user's first name.
                        
                        
                           Last name
                           The user's last name.
                        
                        
                           Password
                           Password for the MID Server user. This password is
                                        specified in the mid.instance.password
                                        parameter of the configuration file that the MID Server
                                        installer creates.
                        
                     
            
         
            Right-click the header and select Save.
         
            Under the Roles related list, click Edit.
         
            Select the mid_server role for this user.
            Each MID Server account must have this role to access protected tables.
         
            Click Save.
         
            Confirm that the MID Server account was created successfully and the account
                    has connectivity to the instance.
            
               
                  On the host machine where you intend to install the MID Server, open a
                            browser and navigate to the instance.
               
               
                  Use your new MID Server user credentials to log in.
                  If the login is successful, then any MID Servers you install on that
                            host will be able to connect to the instance.
               
            
         
   

   ## MID Server role validation

   
   
   Real-time system validation of MID Server role assignments prevents incompatible
    settings.

      
         To prevent MID Server validation failure and ensure that your MID Server is configured
        correctly, the system runs several business rules that monitor the roles and settings you
        select for your MID Server user. The instance displays a warning and blocks the change when
        you attempt to save an incompatible configuration.

      
      ### Elevated privileges not permitted

         
         The mid_server role cannot be configured for elevated privileges. The Invalid
          MID Server settings business rule runs on the Role [sys_user_role] table and
        prevents the elevated_privileges field from being set to true for the
        mid_server role.Figura 1. Warning for elevated privileges on the mid_server role
               
               
            
      
      ### Relationship table protection

         
         The User Role [sys_user_has_role] table creates the relationship between the User
        [sys_user] and the Role [sys_user_role] tables.

         
               Incompatible role
                  The mid_server and security_admin roles are incompatible and cannot be assigned to
              the same user. The system determines the user's current role and runs the
                Security Admin incompatible with MID business rule on the
              User Role [sys_user_has_role] table. This rule prevents an administrator from adding
              the security_admin role for a user who currently has the mid_server role.Figura 2. Warnings for incompatible security_admin role assignment
                        
                        
                     
               Incompatible user role and user record settings
                  The Incompatible MID Server user role business rule runs on
              the User Role [sys_user_has_role] table to protect its data from incompatible
              configurations. Validation for this related table ensures that an administrator cannot
              assign the mid_server role to a user who already holds the security_admin
            role.

            
      
      ### What to do next

         
         Download
        the MID Server files for your operating system.

---


### Download the MID Server files

# Download the MID Server files

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 2 min.  de leituraDownload the MID Server installer package through the instance and make it available for
    installation on the host. Allow the local network to access the authorized IP addresses to
    ensure that you can download the installation package and receive automatic
    upgrades.

      ## Antes de Iniciar
Role required: admin
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         The IP address of the MID Server download site
          (install.service-now.com)  can change without notice. To ensure that
        you can download the MID Server installation package  and receive automatic MID Server
        upgrades, allow local network access to these IP addresses:
               149.96.5.98
               149.96.6.98
            
         A maint user can change the MID Server download site URL with the MID Server system property mid.install_server.base_uri. The MID Server downloads the update files from the new URL instead. Users with
            closed environments can direct MID Servers to update through hosts in their environment. See MID Server properties and [KB1546609] Configure Custom MID server Upgrade URL for more information.

         Nota: Download the MID Server first and then enable Discovery, Orchestration, or any
        integration that requires the use of the MID Server.
      
      ## Procedimento

            On the ServiceNow instance,
          navigate to Mid Server > Downloads.
         
            Select and download the MID Server for the appropriate operating system.
            
               For the best
            performance, install the 64-bit MID Server for your operating system.
               Nota: ServiceNow no longer supports new
          installations of 32-bit MID Servers or upgrades to version Rome. New MID Server
          installation are blocked through RPM and MSI installer on the following operating systems:
            
                  CentOS 7
                  Windows server 2008
                  Windows server 2008 R2
                  Windows 8
                  Windows 10
               MID Servers can be manually installed to any operating system with the ZIP file,
          however Windows 10 is unsupported. Unsupported MID Servers auto-upgrading to Rome create
          an issue record in MID Server Issues (ecc_agent_issue). For more information, see Supported platform changes for MID Server [KB0863694].
               Figura 1. MID Server downloads
                     
                     
                  
            
         
            Save the download file to a temporary file on the local drive.
         
            Move the file into
          the designated MID Server folder you create for your operating system and run the
          installer from that location.
         
      ## O que Fazer Depois

         You can manually verify the signature of an installation package with the jarsigner tool to
        ensure its authenticity. For more information about verifying the signature, see the MID Server upgrades section on
        manual verification.

         Install the MID Server on the host computer.

         
            Linux
            Windows

---


### Install a MID Server on Linux

# Install a MID Server on Linux

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 9 min.  de leituraInstall MID Servers with the MID Server installer and verify it is active. The package
    includes an installer that automatically configures JRE to run in the environment. The MID
    Server can use an existing JRE rather than the provided JRE. Uninstall the MID Server to
    redeploy it.

      ## Antes de Iniciar
Verify that the host computer satisfies the MID Server system requirements.Role required: admin, mid_server
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         To install Linux on MID Server, the RedHat/CentOS systems require RPM while Debian (Ubuntu) systems require DEB. The default installation location is /opt/servicenow/mid. Installing DEB in user defined
            directories is not supported.

         To improve security, this procedure installs and run the MID Server service as a non-root user. Root privilege is required to deploy and configure a MID Server on a Linux server. A non-root user can manage a service only if they
            have the required permissions. For more details, see PolicyKit issues with Linux MID Servers using non-admin accounts [KB0815542].

         Nota: ServiceNow no longer supports new
          installations of 32-bit MID Servers or upgrades to version Rome. New MID Server
          installation are blocked through RPM and MSI installer on the following operating systems:
            
                  CentOS 7
                  Windows server 2008
                  Windows server 2008 R2
                  Windows 8
                  Windows 10
               MID Servers can be manually installed to any operating system with the ZIP file,
          however Windows 10 is unsupported. Unsupported MID Servers auto-upgrading to Rome create
          an issue record in MID Server Issues (ecc_agent_issue). For more information, see Supported platform changes for MID Server [KB0863694].
         Java 21.0.7 is bundled with the MID Server installer package and is installed on the host for all new MID Servers. The installer automatically configures Java 21.0.7 to run in your environment. No additional configuration is required. This version supports both 64-bit Windows
               MID Servers and 64-bit Linux
               MID Servers. The MID Server requires a minimum JRE version 17.0.10, and recommended version 21.0.7. If you are using a lower version than 17.0.10, you may see encryption related issues. 
         Nota: Linux MID Servers require glibC version 2.17. The library must be updated for JRE 11. On 64-bit Linux systems, you must install the 32-bit GNU C library (glibc). The installation command for CentOS is: yum install glibc.i686
         Testing showed that the MID Server
            works as expected with Oracle
            Java 11 version 17.0.10. If you need to upgrade the JRE to a different version, then
            coordinate with the appropriate account representative for support.

      
      ## Procedimento

            On the instance, navigate to MID Server > Downloads and download either the MID Server installer RPM file for RedHat/CentOS or the DEB file for Debian (Ubuntu) systems.
            
               
               Nota: Use the copy link button to copy the download link and use the following wget command to directly download the installers in Linux
                  machines.wget <copied link of the installer>
            
         Opcional: 
            Manually verify the authenticity and integrity of the downloaded file.
            
               
                  Download the signature ZIP files for RPM/DEB.
               
               
                  Run the following commands for either RPM or DEB.
                  
                     RPM

                     
                        Extract the public key, ServiceNow_Digicert_DGST.pem, and
                  signature file from the downloaded signature zip file.
                        Run the following command to verify the signature of the RPM file.
                  openssl dgst -sha256 -verify <Extracted .pem file> -signature <Extracted bin file path> <RPM file path> 
                     
                     DEB

                     
                        Extract the public key, ServiceNow_Digicert_Public.gpg,
                  from the downloaded signature zip files.
                        Import the public key and verify the signature of the DEB file with the
                  following
                  commands.gpg --import <public key> 
dpkg-sig --verify <DEB file path>
                     
                  
               
            
         
            Use the following commands to install either the RPM or DEB installer:
            
               RPM

               
                  Install the RPM package for RedHat systems with the following command:

                     sudo rpm -ivh --nodeps package_name.rpm.
                  Install the RPM package for RedHat systems in a user defined location with the
                following command:

                     sudo rpm -ivh --nodeps package_name.rmp --prefix=/path/to/user/directory.
               
               DEB

               Install the DEB package for Debian systems with the following
            command:sudo dpkg -i package_name.deb.
            
         
            To configure the MID Server service, run the following command from the agent folder as a user with root privilege and provide the required inputs.
            
               ./installer.sh
               
            
         
            The installer.sh script takes the following inputs.
            
               
                  
                     Instance URL
                     Enter the full URL of your instance, for example: https://mycompanyinstace.service-now.com
                  
                  
                     MID-Server Username
                     Enter the user name of the MID Server user that you already created. The MID Server user must have the mid_server role.
                  
                  
                     MID-Server Password
                     Set the password for the current MID Server user.
                  
                  
                     MID-Server Name
                     Set the name of the MID Server.
                  
               
               Proxy Server Information (optional).

               
                  
                     mid.proxy.use_proxy
                     Enables the MID Server to use a web proxy to access the ServiceNow instance.
                  
                  
                     mid.proxy.host
                     Set this parameter to define the web proxy's host.
                  
                  
                     mid.proxy.port
                     Set this parameter to define the web proxy's port.
                  
                  
                     mid.proxy.username
                     If the web proxy requires a user name, set this parameter to define that username.
                  
                  
                     mid.proxy.password
                     If the web proxy requires a password, set this parameter to define that password.
                  
               
               The MID Server can bypass proxy servers whose DNS/IP address is listed in the configuration parameter mid.cloud.discovery.proxy.exclusion.list. See MID Server property for more information.

               To run a MID Server as a daemon service, the following properties are also required.

               
                  
                     app_name
                     Set a unique name for the current MID Server
                  
                  
                     app_long_name
                     Set a unique long name for the MID Server.
                  
                  
                     run_as_user
                     Set the username to run the service as a non-root user.
                  
               
            
         
      ## Resultado
Once all the inputs are entered, the MID Server automatically
      runs as a daemon service and starts the service.
   

   ## Linux MID Server silent installation

   
   
   Silently installing the MID Server uses predefined parameters and requires no user input
  after it is initiated. You can use silent installation on several machines at once to quickly set
  up a network and to ensure all MID Servers have the same installation settings.

      To perform a silent installation with the Linux installer, run the following
   command:./installer.sh -silent -INSTANCE_URL https://instance_name.service-now.com -MUTUAL_AUTH N -MID_USERNAME username -MID_PASSWORD password -USE_PROXY N -MID_NAME mid -APP_NAME mid -APP_LONG_NAME ServiceNow_MID_Server_Mid -NON_ROOT_USER nonrootuser 
      The following fields can be passed through the command line:

      
         
            INSTANCE_URL
            Enter the URL of your instance, for example:
      https://mycompanyinstance.service-now.com
         
         
            MUTUAL_AUTH
            Set this value to Y to use mutual authentication instead of basic authentication. Otherwise,
      set it to N.

               Nota: If MUTUAL_AUTH = Y then provide the path to the certificate with
       CERTIFICATE_PATH.
         
         
            CERTIFICATE_PATH
            If mutual authentication is enabled, provide the path to the certificate.
         
         
            MID_USERNAME
            Enter the user name of the MID Server user that you already created. The MID Server user must have the
     mid_server role.
         
         
            MID_PASSWORD
            Enter the password for the user.
         
         
            USE_PROXY
            Set this value to Y if your MID Server communicates through a proxy to connect to the
      instance.

               Nota: If USE_PROXY = N then skip the other proxy details.
         
         
            PROXY_HOST
            Enter the proxy server host name or IP address. Do not include the protocol in the host
     name. For example: proxyserver.domain.com is correct, but
      https://proxyserver.domain.com is incorrect.
         
         
            PROXY_PORT
            Enter the port the proxy server uses to communicate. If this value is blank, the installer
     uses the proxy server's default port number.
         
         
            PROXY_USERNAME
            Enter the username that has administrator rights to the proxy server.
         
         
            PROXY_PASSWORD
            Enter the password for the username.
         
         
            MID_NAME
            Enter the MID Server name.
         
         
            APP_NAME
            Provide the service name. It must be unique for the current MID Server.
         
         
            APP_LONG_NAME
            Provide the service long name.
         
         
            NON_ROOT_USER
            Provide the username to run the service as a non-root user.
         
      
      The following is an example command for a MID Server which uses a proxy and mutual
   authentication:

      ./installer.sh -silent -INSTANCE_URL https://instance_name.service-now.com MUTUAL_AUTH Y –CERTIFICATE_PATH <path-to-certificate> -USE_PROXY Y -PROXY_HOST <ip> -PROXY_PORT <port> -PROXY_USERNAME <username> -PROXY_PASSWORD <password> -MID_NAME proxymid -APP_NAME proxymid -APP_LONG_NAME servicenow_proxy_mid -NON_ROOT_USER nonrootuser 
      Nota: To reconfigure the MID Server, run the installer.sh command again.
    Reconfiguring the MID Server deletes the old configuration. 
   

   ## Run Linux MID Servers as non-root users

   
   
   Run MID Servers as non-root user on a Linux machine to improve security. Multiple MID
        Server can be installed as services so they can start by themselves after system reboots.

      ### Antes de Iniciar
Role required: rootThis process is only applicable if you
                installed the MID Server manually using the ZIP file. If you installed the MID
                Server with the procedure in Install a MID Server on Linux, then
                the MID Server is already running as a non-root user.

         Supported versions for
                this procedure are Linux Red Hat 6 or newer, Ubuntu 1404 or newer, and CentOS 6 or
                newer.
            

      
      ### Procedimento

            Stop any MID Server running on the host with the command bin/mid.sh
                        stop.
         
            Remove any MID Servers on the host with the command bin/mid.sh
                        remove.
         
            Edit the file mid.shconf_override.
            
               
            
         
            Add the MID Server's name using the lines APP_NAME= and
                        APP_LONG_NAME= to run it as a service.
            To prevent errors, the APP_NAME of each MID Server must
                    be unique.
         Opcional: 
            To run multiple MID Servers as services on the same host, add an
                        APP_NAME and APP_LONG_NAME for
                    each instance.
            
               
            
         
            Add the name of the non-root user to operate the account using the line
                        RUN_AS_USER=.
         Opcional: 
            Add the name of the group to own the entire agent directory using the line
                        GROUP_NAME=.
         
            Set the line PROMPT_BEFORE_OWNERSHIP_CHANGE= to
                        true to prompt the user for confirmation before any
                    changes to file permissions are applied.
            The file permission change is applied to the entire agent folder and
                    everything inside recursively. The changes include blocking other users' the
                    access to the entire agent folder, changing the owner to
                        $RUN_AS_USER if specified, and changing the group to
                        $GROUP_NAME if specified.
         
            Reinstall the MID Server with the command bin/mid.sh
                        install.
            
               Nota: To prevent errors, make sure to stop and remove any existing MID Server
                            services before starting new ones. During the first installation, a root
                            user is required to call bin/mid.sh install.
                            Reinstalling the MID Server applies the changes in
                                mid.shconf_override. Then the non-root user
                            specified in mid.shconf_override is able to
                            start/stop/restart the service without elevated privileges.

            
         
      ### O que Fazer Depois

         For more information about managing the allow list and file permission enforcement,
                see File permission enforcement for Windows MID Servers. Running a Linux MID
                Server with a non-root account may result in issues with PolicyKit in some systems.
                See PolicyKit issues with Linux MID Servers using
                    non-root accounts for more information.

      
   

   ## Configure a Linux MID Server to use an existing JRE

   
   
   You can choose to use an
                    existing JRE for your MID Server rather than the OpenJDK provided with the MID
                    Server installer. 

      ### Antes de Iniciar

         Ensure that your JRE version
                    is supported. See MID Server system requirements for details.
         Role required: admin

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         By electing to use your own
                    JRE, you are responsible for upgrading it as necessary. For a detailed procedure
                    and cautions regarding changing the JRE, see KB0778272.
      
      ### Procedimento

            Navigate to this file in the MID Server installation directory:
            
               agent/conf/wrapper-override.conf
            
         
            To specify the existing Java executable that you want to use, add this line to
                    the file:
            
               wrapper.java.command={your_java_executable}
               For
                        more information, see the Java service wrapper property documentation.

            
         
            Save the file.
         
   

   ## Uninstall a Linux MID Server

   
   
   The MID Server runs as a stand-alone service. You can
          remove a stand-alone MID Server service to accommodate such tasks as redeploying the MID
          Server to another host machine or changing the unique name of a MID Server when deploying
          multiple MID Servers.

      ### Antes de Iniciar

         Role required: admin

      
      ### Procedimento

            Run the uninstall.sh script in the agent folder to
                    remove the service and uninstall the RPM/DEB.
            
               
            
         
      ### Resultado

         The MID Server service is uninstalled.

      
      ### O que Fazer Depois

         Validate the MID
                Server to prepare it for use.

---


### Install a MID Server on Windows

# Install a MID Server on Windows

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 17 min.  de leituraInstall MID Servers with the MID Server guided Windows installation package. The package
  includes an installer that automatically configures OpenJDK to run in the environment. The MID
  Server can use an existing JRE rather than the provided OpenJDK. Uninstall the MID Server to
  redeploy it.

      
                  
                     
                  
               
      
         
            Verify that the host computer satisfies the MID Server system requirements.
            The MID Server requires the minimum PowerShell version 3.0 and supports versions up to
     PowerShell 5.1.
            Ensure that the Microsoft Application Experience Lookup Service is enabled on the MID Server
     host. If this service is disabled, the MID Server auto-upgrade might fail, causing the MID
     Server to go down. For information on managing issues with the Application Experience service,
     see KB0597552.
         
         Java 21.0.7 is bundled with the MID Server installer package and is installed on the host for all new MID Servers. The installer automatically configures Java 21.0.7 to run in your environment. No additional configuration is required. This version supports both 64-bit Windows
               MID Servers and 64-bit Linux
               MID Servers. The MID Server requires a minimum JRE version 17.0.10, and recommended version 21.0.7. If you are using a lower version than 17.0.10, you may see encryption related issues. 
         Nota: ServiceNow no longer supports new
          installations of 32-bit MID Servers or upgrades to version Rome. New MID Server
          installation are blocked through RPM and MSI installer on the following operating systems:
            
                  CentOS 7
                  Windows server 2008
                  Windows server 2008 R2
                  Windows 8
                  Windows 10
               MID Servers can be manually installed to any operating system with the ZIP file,
          however Windows 10 is unsupported. Unsupported MID Servers auto-upgrading to Rome create
          an issue record in MID Server Issues (ecc_agent_issue). For more information, see Supported platform changes for MID Server [KB0863694].
         Testing showed that the MID Server
            works as expected with Oracle
            Java 11 version 17.0.10. If you need to upgrade the JRE to a different version, then
            coordinate with the appropriate account representative for support.

         Upgraded MID Servers might use different Java versions depending on
        their operating system versions.
               MID Servers upgraded from earlier versions use the OpenJDK provided with the MID
            Server installer. This version of the OpenJDK was tested and certified for use with
            these MID Servers.
               MID Servers upgraded on any other operating system versions also automatically upgrade the JRE to the version provided with the installation package.
            
      
   

   ## Install a MID Server on Windows with guided installation

   
   
   Install MID Servers with the MID Server guided Windows installation package. The
    package includes an installer that automatically configures OpenJDK to run in the
    environment.

      ### Antes de Iniciar

         Role required: admin or mid_server

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         The MID Server guided native Windows installer will configure the MID Server with provided
        settings. The installer creates the MID Server Service and assigns it to the provided user.
        The installer sets the file permissions on the MID Server Install folder. The installer
        allows for the configuration of proxy settings. Optionally, the installer can start the MID
        Server automatically.

      
      ### Procedimento

            On the instance, download the MID Server installation .msi file from MID Server > Download.
         
            Log in to the Windows host machine where you want to install the MID Server.
         
            Place the installer .msi on the desired MID Server host.
         
            Open the installer with Administrator level privileges.
         
            Use the installer to enter the following information.
            
               

               
                        
                           Field
                           Description
                        
                     
                        
                           Authentication Type
                           
                                 
                                    Basic
                                    Username and password based authentication.
                                 
                                 
                                    Mutual
                                    Client certificate based authentication. See MID Server unified key store for more information on
                          mutual authentication.
                                 
                              
                              Nota: Selecting mutual authentication disables the MID Server username and
                      password fields. The disabled fields are not written to
                        config.xml.
                        
                        
                           ServiceNow instance URL
                           Enter the full URL of your instance, for example:
                        https://mycompanyinstace.service-now.com

                        
                        
                           ServiceNow MID Server username
                           Enter the name of the MID Server user
                    that you already created. The MID Server user must have the mid_server
                    role.
                        
                        
                           ServiceNow MID Server password
                           Enter the password for the user in the ServiceNow MID Server
                      username.
                        
                        
                           Certificate Revocation
                           This check box is selected by default to enable certificate revocation
                      policies to improve security. For more information on certificate revocation,
                      see MID Server certificate check policies.

                              When testing a connection with certificate revocation enabled, the installer
                      checks if OCSP port 80 is open and the entrust page is accessible.

                              If the connection test fails due to the certificate revocation check, the
                      error must either be corrected and re-tested or the certificate revocation
                      check must be disabled. The certificate revocation check is not required for
                      successful installation.

                        
                        
                           Use proxy
                           Select this check box if your MID Server communicates through a proxy to connect to the instance.Nota: Your proxy server must use Basic Authentication for the MID server to connect to the instance.The MID Server can bypass proxy servers whose DNS/IP address is listed in the configuration parameter mid.cloud.discovery.proxy.exclusion.list. See MID Server property for more information.

                        
                        
                           Proxy host
                           Enter the proxy server host name or IP address. Do not include the protocol
                    in the host name. For example, enter proxyserver.domain.com,
                    not https://proxyserver.domain.com.
                        
                        
                           Proxy port
                           Enter the port through which the proxy server communicates. If you leave
                    this field blank, it should use the proxy server's default port number.
                        
                        
                           Proxy username
                           Enter the user name that has administrator rights to the proxy
                    server.
                        
                        
                           Proxy password
                           Enter the password for the user name.
                        
                     
            
         
        Click Test your connection to validate the credentials and instance information.
        If you encounter any errors, verify the information that you input.
      
            Click Next.
         
            Configure the MID Server name and Service Account parameters (see
          table).
            
               

               
                           
                              Field
                              Description
                           
                        
                           
                              MID Server name
                              Enter a MID Server name.Aviso: MID Server names cannot
                        begin with mid.server.
                           
                           
                              Service Account Name
                              Username of the service account that will be used to run the MID Server
                        service. For information on creating service accounts, see Create a Windows service account with "Log
                          on as Service" [KB0867669].

                                 Service Account Name field is an editable drop-down menu. Either select a
                        value from the drop-down or type a new value in the text field. Only the
                        accounts with log on as service policy are displayed in
                        the drop-down. Group Managed Service Accounts (gMSA) that inherit the
                          log on as service policy from their groups are not
                        displayed in the drop-down. However, you can install the MID Server service
                        using those accounts by manually entering the service account name in the
                        editable drop-down. The name can follow three formats.

                                 
                                    If the service account is local to the computer, you can give just the
                            name.Example: My_Local_Service_Account

                                    If the service account is local to the computer, you can provide “.” as
                          the domain name for the account.Example:
                          .\My_Local_Service_Account

                                    Any account can follow the format {domain}\{username}.Example:
                            MY-COMPUTER-DOMAIN\My_Domain_Service_Account

                                 
                                 Add a new local service account by selecting the +
                        button. This button opens the Configure New Local
                          User window, which has three fields. 
                                       Service Account Name: Enter the name of the new
                            service account.
                                       Service Account Password: Enter the password of
                            the new service account.
                                       Re-enter Password: Confirm the password of the
                            new service account.
                                    
                                 When a group Managed Service Account (gMSA) user is selected, the password
                        field is removed because passwords for gMSA users are managed by the Active
                        Directory.

                                 Nota: The provided service account credentials must meet the following
                          requirements in addition to being a valid account.

                                    
                                       The user cannot be a local system or an administrator level account
                            (local admin, domain admin, etc.)
                                       The service account provided has the log on as
                              service right, which is required for an account to be used
                            as the log on user for a service.
                                    
                           
                           
                              Service Account Password
                              Password of the service account that will be used to run the MID Server
                      service.
                           
                           
                              Set Service Name Manually
                              Select this check box if you want to manual set the service name and
                        display name for your MID Server.

                                 Note: Your proxy server must use Basic Authentication for the MID server to
                        connect to the instance.

                           
                           
                              MID Service wrapper name
                              Modify this field if necessary. It is populated automatically by
                      prefixing snc_mid_ to the MID Server name. In most cases, you
                      do not need to modify this.
                           
                           
                              MID Server wrapper display name
                              Modify this field if necessary. It is populated automatically by
                      prefixing ServiceNow MID Server_ to the MID Server name. In
                      most cases, you do not need to modify this.
                           
                        
            
         
            Click Next and select a destination folder for the
          installation.
            
               Users can manually enter an existing, valid file path, or use the “Change” button to
            open up a browsing page where they can choose the install location.

            
         
            Click Next to view the summary.
            
               
            
          
               Select Start MID Server after installation if you want to start
            the MID Server immediately after installation. If you wish to make additional
            configuration changes, before starting the MID server, leave this box unchecked. If
            mutual authentication was selected, the MID Server username and password fields are
            removed.

               Nota: If the MID Server fails to start, the cause might be a duplicate name or multiple
            services that point to the same executable path. This can happen when you have MID
            servers previously not installed through the installer. See MID Server fails to start for details.
            
         
            Click Mid Servers List Page.
            The installer opens the MID Server list from your instance.
         
            Select the MID Server name from the list.
            
               Nota: It may take a few seconds for the MID Server time to establish a connection with
            your instance.
            
            The system displays the MID Server record.
         
            From Related Links, click Validate.
            The MID Server Validated changes to
            Yes.
         
      ### O que Fazer Depois

         To upgrade the MID Server, see MID Server upgrades for
        procedures and requirements.

      
   

   ## Uninstall a Windows MID Server with the guided installer

   
   
   The MID Server guided native Windows installer also supports guided uninstallation of
        the MID Server.

      ### Antes de Iniciar
Role required: adminThere are three ways to uninstall a MID Server after
                installing it with the guided native Windows installer.

      
      ### Procedimento

            On the MID Server host, navigate to the Control Panel > Programs > Programs and Features > Uninstall a program.
            
               
                  Uninstall the program with the MID Server's name.
               
            
         Opcional: 
            Alternatively, navigate to Settings > Apps
            
               
                  Uninstall the program with the MID Server's name.
               
            
         Opcional: 
            The MID Server can also be uninstalled with the silent uninstall script.
            This is useful for uninstalling multiple MID Servers. For more information,
                    see Windows MID Server silent installation and uninstallation
            
         
   

   ## Configure Windows MID Server service credentials

   
   
   MID Server service credentials are required to manage the MID Server service on the host
        machine, including its ability to successfully auto-upgrade.

      ### Antes de Iniciar

         Role required: admin

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         If you installed the MID Server using the native installer, you will not need to
                complete this procedure. However, to change the service user after the installation
                for any reason, use this procedure.

         Windows service credentials control the level of privilege on the device. The user
                should not be a local system or an administrator level account (local admin, domain
                admin, etc.) The service account provided should have the log on as
                    service right, which is a requirement for an account to be used as
                the log on user for a service.

         Nota: Windows service credentials are not the same as the MID Server user credentials, which allow communication between the MID Server and the instance. You must configure both of these credentials separately. See Create the MID Server user and grant the role for instructions on MID Server user credentials.

      
      ### Procedimento

            Open the Windows Services console.
         
            Double-click the 
                  ServiceNow
               
               <MID Server name> service for each MID Server.
         
            Select the Log On tab.
         
            Choose a non-admin user and provide the password for that user.
         
            In the General tab, set the Startup
                        type.
            The field is set to Automatic by default.
         
            Click OK.
         
            Restart the ServiceNow <MID Server name> service, and make sure that ServiceNow\<MID Server name>\agent\logs\agent0.log does not have error messages.
             If the MID Server does not start, see the ServiceNow knowledge article Review the agent log for MID Server errors (article KB0535148).
         
            On the instance to which this MID Server is connected, navigate to MID Server > Servers.
            
               If Discovery is installed, alternately navigate to Discovery > MID Servers. All MID Servers connected to this instance are listed.

            
         
            Make sure that the Status of the MID Server that you just installed is Up.
         
   

   ## Windows MID Server silent installation and uninstallation

   
   
   Silently installing the MID Server uses predefined parameters and requires no user input
  after it is initiated. You can use silent installation on several machines at once to quickly set
  up a network and to ensure all MID Servers have the same installation settings.

      ### MID Server silent installation

         
         Nota: All silent install/uninstall commands must be run with administrator level
        privileges.
         To silently install the MID Server on a Windows system, download the script attached to the
        Knowledge Base article Windows MID Server silent installation and uninstallation. Place
        the file on the target MID Server host machine and run the following command from the
        command prompt. You can also run the script directly from
        powershell.powershell -command “.\SilentInstall.ps1 -<parameter_name1> ‘<value for parameter1>’ -<parameter_name2> ‘<value for parameter2>’ etc…”
         The script checks the following mandatory parameters:
               MSI_FILE_NAME: the name of the MSI file used for the
      installation.
               INSTALL_LOCATION : the location to install the MID Server.
               INSTANCE_URL: the target ServiceNow instance the MID Server will connect to.
               MID_USERNAME: the instance account name.
               MID_PASSWORD: the instance account password.
               MID_NAME: the name of the MID Server.
               SERVICE_ACCOUNT_NAME: the name of the service account.
               SERVICE_ACCOUNT_PASSWORD: the password of the service account.
            
         The following parameters are optional:
               LOG_NAME: enables logging and puts logs into the file named by
            this parameter.
               START_MID: sets the MID Server to start automatically after the
            installation finishes.
               USE_PROXY: enables the use of a proxy. If you choose this
            command, the following parameters become mandatory.
                     PROXY_HOST: the name of the proxy host.
                     PROXY_PORT: the port number of the proxy.
                     PROXY_USERNAME: the proxy username. If there is no username,
                input ‘’.
                     PROXY_PASSWORD: the proxy password. If there is no password,
                input ‘’.
                  
               MANUAL_SERVICE_NAME: the service name. If you choose this
            command, the following parameters become mandatory:
                     SERVICE_NAME: the service name.
                     SERVICE_DISPLAY_NAME: the service display name.
                  
               MUTUAL_AUTH: enables mutual authentication. If this switch is
            enabled, MID_USERNAME and MID_PASSWORD are not
            required. See MID Server unified key store for more
            information.
            
            Nota: The parameters START_MID, USE_PROXY,
            MUTUAL_AUTH, and MANUAL_SERVICE_NAME are
          switches. They use the format -<switch_param_name> and are not
          followed by a value.
         After the script runs, verify the MID Server files, service, and entry in Programs and
    Features are installed. If you enabled logging, verify the log info in the file specified by the
     LOG_NAME parameter.

      
      
         An example MID Server silent installation command:

         powershell -command ".\SilentInstall.ps1 -MSI_FILE_NAME 'MID-Installer.msi' -INSTALL_LOCATION 'C:\Users\Administrator' -INSTANCE_URL 'https://my-instance-name.service-now.com' -MID_USERNAME 'mid_server' -MID_PASSWORD 'mid_password' -MID_NAME 'Silent_Install_MID' -SERVICE_ACCOUNT_NAME 'DOMAIN\My_Service_Account' -SERVICE_ACCOUNT_PASSWORD 'Service_Account_Password' -LOG_NAME 'Silent_Install_Log.txt'"
      
      
         An example command using the START_MID switch:

         powershell -command ".\SilentInstall.ps1 -MSI_FILE_NAME 'MID-Installer-Wix.msi' -INSTALL_LOCATION 'C:\Users\Administrator' -INSTANCE_URL 'https://my-instance-name.service-now.com' -MID_USERNAME 'DOMAIN\My_Service_Account' -MID_PASSWORD 'mid_password' -MID_NAME 'Silent_Install_MID' -SERVICE_ACCOUNT_NAME 'DOMAIN\My_Service_Account’ -SERVICE_ACCOUNT_PASSWORD 'Service_Account_Password' -LOG_NAME 'Silent_Install_Log.txt' -START_MID"
      
      ### MID Server silent uninstallation

         
         To silently uninstall the MID Server on a Windows system, download the script attached to
        the Knowledge Base article Windows MID Server silent installation and uninstallation. Then
        run the script using the command prompt. It can also be run directly from
        powershell.powershell -command “.\SilentUninstall.ps1 -MID_NAME ‘<value for MID_NAME>’ -LOG_NAME ‘<value for LOG_NAME>’”
         The script requires the mandatory parameter MID_NAME, which is the name
        of the MID Server you want to uninstall.

         The optional parameter LOG_NAME enables logging of the uninstallation and
        puts logs into the file named by this parameter.

         After the script runs, verify the MID Server files, service, and entry in Programs and
    Features are uninstalled. If you enabled logging, verify the log info in the file specified by
    the LOG_NAME parameter.

      
      
         An example MID Server silent uninstall command:

         powershell -command ".\SilentUninstall.ps1 -MID_NAME 'silent_install_cmd' -LOG_NAME
      'uninstall.txt'"
      
   

   ## Manually install a MID Server on Windows

   
   
   Install MID Servers with the ZIP file installation package and verify it is
    active.

      ### Antes de Iniciar

         Role required: admin or mid_server

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         Click this link to view the installation video:

         MID Servers can be configured to run using non-administrative accounts. Using non-admin
            accounts in conjunction with file permission enforcement can improve security by
            restricting access to MID Server files. sIf you choose to run a MID Server with a
            non-admin account, there are limitations that change the behavior of other applications.
            The following behavior changes can occur:
               The MID Server account needs appropriate credentials to run a Discovery schedule.
                  If the credentials are insufficient, the MID Server falls back to the user
                  account's privileges. A non-admin user account may not have the necessary
                  privileges to access the Discovery target.
               Enhanced Application Dependency Mapping (ADME) and File Based Discovery (FBD) may
                  not work by default. To correct this issue, non-admin users need to be given
                  permission to read/write to the Admin Share folder.
            
      
      ### Procedimento

            Log in to the Windows host machine where you want to install the MID Server.
         
            Create a folder for the MID Server on the top level of the drive such as
            ServiceNow\MID Server1.
         
            Download the MID archive file into the new folder.
         
            Right-click the archive and select Extract All.
         
            Navigate to the service-now\<mid server
            name>\agent folder that was created when the file was
          extracted.
         
            To configure the MID Server manually, edit the config.xml file
          with a text editor such as WordPad:
            
               
                  Find the element  <parameter name="url"
                value="https://YOUR_INSTANCE.service-now.com" /> element and change
              the value to the URL of your instance.
               
               
                  Enter the MID user credentials in the mid.instance.username 
              and mid.instance.password  parameters.
                  By default, the MID Server, uses basic authentication for SOAP messages. The
              password value is also encrypted authentication. 
               
               Opcional: 
                  Find the  <parameter name="name" value="YOUR_MIDSERVER_NAME_GOES_HERE"
                /> element and change the value for the MID Server name.
               
               Opcional: 
                  Enter connection information for the proxy server.
                  Remove the appropriate comment tags from the proxy configuration information.
                  For example, you can configure these parameters: 
                        mid.proxy.use_proxy
                        mid.proxy.host
                        mid.proxy.port
                        mid.proxy.username
                        mid.proxy.password
                     
                  
               
            
         Opcional: 
            If you want to install the MID Server as a non-admin user, follow these
               steps.
            
               
                  Edit the .\conf\wrapper-override.conf file.
               
               
                  Uncomment the wrapper.ntservice.account property and specify
                     the Service Account Name.
               
               
                  Either uncomment wrapper.ntservice.password.prompt, or
                     uncomment wrapper.ntservice.password and provide a
                     password.
                  Enabling wrapper.ntservice.password.prompt prompts for a
                     password when installing the service. Enabling
                        wrapper.ntservice.password sets a password immediately but
                     is less secure.
               
               
                  Uncomment the wrapper.ntservice.permissions.1.account and
                     specify the Service Account Name.
               
               
                  Uncomment wrapper.ntservice.permissions.1.allow but do not
                     edit it.
               
               
                  Uncomment wrapper.name and specify the desired service name,
                     and uncomment wrapper.displayname and specify the desired
                     display name.
                  The wrapper.name must be unique on the host and no other
                     service can share the same name.
               
            
         
            Run start.bat to start the MID Server.
             If wrapper.ntservice.password.prompt was set in step 7c, enter
               the password when prompted. If there is no password, proceed without entering
               one.
         
            On the instance, in the Related Links, select
            Validate.
            The MID Server Validated changes to
            Yes.
         
   

   ## Uninstall a Windows MID Server after manual installation

   
   
   The MID Server runs as a stand-alone service. You can
          remove a stand-alone MID Server service to accommodate such tasks as redeploying the MID
          Server to another host machine or changing the unique name of a MID Server when deploying
          multiple MID Servers.

      ### Antes de Iniciar

         Role required: admin

         This procedure is only for users who install the MID Server using the ZIP file.

      
      ### Procedimento

            Stop the running MID Server service, using either of these procedures:
            
               
                  Windows command line: From the MID Server home
                                (agent) directory, run
                                stop.bat.
                  Windows Services console: From the Windows
                            Services console, right-click the ServiceNow
                     MID Server name and then select
                                stop.
               
            
         
            From a command prompt, go to the \agent\bin directory in
                    the MID Server installation directory and double-click the
                        UninstallMID-NT.bat file.
         
      ### O que Fazer Depois

         Validate the MID
                Server to prepare it for use.

      
   

   ## Configure a MID Server on Windows to use an existing JRE

   
   
   You can choose to use an
                    existing JRE for your MID Server rather than the OpenJDK provided with the MID
                    Server installer. 

      ### Antes de Iniciar

         Ensure that your JRE version
                    is supported. See MID Server system requirements for details.
         Role required: admin

      
      ### Por Que e Quando Desempenhar Esta Tarefa

         By electing to use your own
                    JRE, you are responsible for upgrading it as necessary. For a detailed procedure
                    and cautions regarding changing the JRE, see KB0778272.
      
      ### Procedimento

            Navigate to this file in the MID Server installation directory:
            
               agent/conf/wrapper-override.conf
            
         
            To specify the existing Java executable that you want to use, add this line to
                    the file:
            
               wrapper.java.command={your_java_executable}
               For
                        more information, see the Java service wrapper property documentation.

            
         
            Save the file.

---


### Validate the MID Server

# Validate the MID Server

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 2 min.  de leituraYou must manually validate the MID Server after it is
            installed to enable it to execute automation tasks. You can invalidate a MID Server you
            suspect has been compromised to prevent it from accessing automation credentials in the
            instance or executing outbound ECC probes.

      ## Antes de Iniciar
Role required: agent_admin, admin
                  
                     
                  
               
         Make sure that the MID Server
                    version is compatible with the instance.

      
      ## Por Que e Quando Desempenhar Esta Tarefa

         Validation restricts access to automation credentials
                to trusted MID servers only.
         When you validate a MID Server, you specify the
                capabilities it can use, the applications that use it, and the IP ranges it is
                allowed to explore. You will be prompted to set the initial selection criteria when
                you validate MID Servers that do not already have capabilities, applications, or IP
                ranges already configured. You do not have to set the initial selection criteria to
                actually validate the MID Server. See MID Server selection for more information on
                capabilities, applications, and IP ranges.Nota: When you upgrade, MID Servers that
                    are already configured in your instance are automatically validated. This
                    prevents the interruption of automation tasks that MID Servers might be
                    performing. See MID Server upgrades
                    for more information.
      
      ## Procedimento

            Navigate to All > MID Server > Servers.
         
            Open the new MID Server you created from the list of MID Servers.
         
            Under Related Links click
                        Validate.
            The Set Initial Selection Criteria window appears if there are no records in
                    the Supported Applications, IP Ranges, or Capabilities related lists.
         
            On the Set Initial Selection Criteria window, use the switches to enable or
                    disable selection criteria for this MID Server:
            
               
                  Allow ALL capabilities: Allow all capabilities
                            for Orchestration and Event Management to use this MID Server.
                                Nota: Service Mapping and Event Management alert aggregation and
                                RCA, which used capabilities in previous releases, rely on the
                                application for MID Server selection.
                  Allow ALL applications: Allow all applications
                            that use MID Servers to use this MID Server.
                  Allow ALL IP ranges: Make all IP ranges valid for
                            this MID Server, meaning that it can target any IP address.
               
               Figura 1. Setting initial selection criteria
                     
                     
                  
               If you click Cancel, the validation continues but none
                        of the capabilities, applications, or IP ranges are added.

            
         
            Click OK.
            
               The Validated field on the dashboard is set to
                            Validating, and then set to
                            Yes after the validation completes.

            
         
            To invalidate a MID Server, open the record for the MID Server you suspect has
                    a security issue.
         
            Under Related Links, click
                        Invalidate.
            Invalidating a MID Server forces it to clear its memory and restart. The MID
                    Server generates a new keypair on restart.
         
      ## O que Fazer Depois

         Test
                    network connectivity to ensure that the MID Server can upgrade
                automatically.

      
   
   Tarefas relacionadas
Rekey a MID Server

---


### Test MID Server connectivity

# Test MID Server connectivity

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 2 min.  de leituraConfirm that the MID Server host is able to communicate with the instance. Resolve
        any issues with the network connectivity such as conflicts with firewalls, access control
        lists, and routing errors. Successful communication is necessary for automatic
        upgrades.

      ## Antes de Iniciar
Role required: admin
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         The computer that hosts the MID Server must be able to access one of these URLs to
                upgrade automatically:
               HTTPS: https://install.service-now.com on the default HTTPS port
                            (443)
               HTTP: http://install.service-now.com on the default HTTPS port
                            (80)
            
      
      ## Procedimento

            Use PING to test connectivity with the host on the network (ping<host
    IP>).
         
            If no ping response is returned, use TRACEROUTE to see where traffic might be stopped (traceroute<host>).
         
            Use TELNET to connect to any of the TCP ports (telnet<host> <port>).
         
            Use an SNMP scanning tool to determine if a potential network device is
    responsive.
         
            Resolve the most likely issues around network connectivity:
            
               
                  Routing: Confirm that the MID Server host has network access to the IP
                        ranges you are attempting to discover.
               
                  Firewalls: Confirm access to the physical firewalls that protect a large
                        environment such as the Data Center. Confirm access to any logical firewalls
                        that protect an individual computer. MID Server communications are initiated
                        inside the firewall and therefore do not require any special firewall rules
                        or VPNs.
               
                  Access Control Lists (ACL): Confirm that ACLs contain the IP addresses
                        based list on SNMP network devices that allows communication to a particular
                        target.
               
                  Resolve all issues with your network teams to better understand your topology.
Deploy additional MID Servers if necessary to help keep your network secure. Configure access from your existing MID Server host to networking components.

            
         
            Verify that the MID Server service is running on the host:
            
               
                  Windows: In the Windows Services console, locate the
                            ServiceNow [MID Server name] and confirm that
                        each MID Server has the Started Status
                        value.
               
                  Linux: Ensure that the
                            agent0.log.0.lck appears in the
                            /servicenow/ MID Server name]/agent 
                        folder.
            
         
            After each MID Server restart, open the agent0.log.0  and
                    address all error messages.
         
            From the ServiceNow
                    instance, navigate to MID Server > Servers.
         
            Review and verify that all MID Servers that are connected to the instance are
                    listed.
         
            Verify that the Status is Up for
                    the MID Servers.
         
      ## O que Fazer Depois

         This concludes the installation of a single MID Server. If necessary, continue to
                    deploy multiple MID
                    Servers from a single host in your network. Otherwise, begin configuring your MID
                    Server.

---


### Install multiple MID Servers on a single system

# Install multiple MID Servers on a single system

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 5 min.  de leituraInstall multiple MID Servers on the same host computer. Multiple MID Servers can support
        each other with load balancing, as well as use domain separation. The number of MID Servers
        required is determined by factors like network policies, security restraints, and the
        reliability of the host computer.

      ## Antes de Iniciar
Role required: admin, mid_server
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa

         You can install multiple MID Servers on a Linux or Windows host or on a virtual
                machine. Installing multiple MID Servers may involve other setup steps depending on
                your network configuration.Importante: Only one MID Server service can be
                    a daemon on a Linux host. This is a limitation of the Tanuki wrapper
                    service.
      
      ## Procedimento

            Log in to the host system or virtual machine where you want to install multiple
                    MID Servers.
         
            Create a directory for each MID Server on the top level of the drive.
            
               Make sure you create a unique and descriptive name for each MID Server, such
                        as MIDServer_SMS_Int or MIDServer_Disc1.

            
         
            Extract the downloaded MID Server archive file into each MID Server
                    directory.
            When the extract completes, there should be a directory path similar to
                    the following for each MID Server: ServiceNow<MID Server
                        name>\agent. 
         
            For each MID Server, run the installer appropriate to the host's operating
                    system.
            
               Tabela 1. MID Server installers
                        
                           Operating System
                           Installer path
                        
                     
                        
                           Windows
                           /agent/start.bat
                        
                        
                           Linux
                           /agent/installer.sh
                        
                     
            
         
            Use the installer to enter the following information.
            
               
                  URL to your instance
                  User credentials to run the MID Server
                  Proxy server connection details
                  MID server name
                  MID server service wrapper name and display name (Windows systems
                            only)
               
               Nota: The MID Server user must have the mid_server role.
            
         
            From the installer, click Start MID Server.
            
               
                  

               
            
            The local host starts the MID Server.
         
            Click Mid Servers List Page.
            The installer opens the MID Server list from your instance.
         
            Select the MID Server name from the list.
            
               Nota: It may take a few seconds for the MID Server time to establish a
                        connection with your instance.
            
            The system displays the MID Server record.
         
            From Related Links, click
                        Validate.
            The MID Server Validated changes to
                        Yes.
         
      ## O que Fazer Depois

         All MID Server installation procedures are complete. Proceed to configure your MID
                Server.

      
   

   ## Multiple MID Server deployments

   
   
   Depending upon how you use the MID Server (for an external integration, Discovery, Service Mapping, or Orchestration) and the load placed on it,
    you might find it necessary to deploy multiple MID Servers in your network.

      Factors determining the number of MID Servers your network will require to support external
      applications that integrate with ServiceNow include the following:
            The security constraints in your network.
            Your network policies.
            The amount of traffic between ServiceNow and the integrations.
            The reliability of the MID Server machines.
         
      ### Network policies and security

         
         Security policies in your network (firewalls between network segments, for example) might
        make direct communication impossible between your instance and an integration's data source
        (JDBC, LDAP, etc.). To retrieve data for the instance, you can install a MID Server that has
        access to both the data source and the instance.

         These network policies can determine if you need to install multiple MID Servers in your
        environment: 
               Access control lists (ACL): If your security policy controls
            access to network devices (e.g. switches and routers) with an ACL, it might be necessary
            to install one or more MID Servers on a machine in the network that is already on the
            ACL.
               DMZ: Your network policy might require you to install one or
            more MID Servers in your DMZ to probe the devices there. This is common in networks that
            tightly regulate the ports that are opened on the inside firewall.
               Probe types: If you are conducting probes of different
            operating systems, your network policy might require a separate MID Server for each type
            of probe (e.g., one MID server for Windows WMI probes and another for
            SSH probes on UNIX).
            
      
      ### Load balancing

         
         Deploy multiple MID Servers where capacity is an issue, as when Discovery has to gather information
        about thousands of configuration items quickly. In a high volume environment, it might be
        necessary to deploy multiple MID Servers as load balancers for certain transactions. For
        example, JDBC data transfers can tie up the resources of a MID Server, making it unable to
        respond to other requests. The following operations between an integration might require
        separate MID Servers in a busy network:
               File exports
               Running scripts
               JDBC data sources
               Reading files
            
      
      ### High availability model

         
         Avoid installing MID Servers for critical integrations on a machine that might experience
        any type of planned outage or an outage caused by overloaded processes. If necessary for
        reliability, consider deploying these types of MID Servers to dedicated machines for high
          reliabilityNota: Do not integrate with an external application on a MID Server
          provisioned for ServiceNow
               Discovery or
        Orchestration.
      
      ### Wide area network (WAN)

         
         When determining where to deploy MID Servers in a WAN, consider the bandwidth available
        between your local area networks. In most cases, install a MID
        Server on each LAN to probe devices locally, rather than deploying MID Servers that must
        probe devices across slow WAN connections. An alternative to this type of deployment is to
        install MID Servers that probe other LANs via VPN connections that take advantage of fast
        Internet connections. If the bandwidth of your WAN connections is comparable to that of your
        Internet connection, then there is no performance impact in running MID Server probes across
        WAN connections.

      
      ### Domain separation

         
         In deployments where domain separation is enabled and domains are configured to form a
        hierarchy, place the MID Servers at the lowest domain level.

         Figura 1. Deploying MID Servers with domain separation

---


### Use MID Server guided setup

# Use MID Server guided setup

   
   
    Versão de lançamento:  Australia Atualizado 12 de mar. de 2026 3 min.  de leituraMID Server guided setup provides a sequence of tasks that help you install a MID
        Server with the proper user account and validate the MID Server. If you are setting up a MID
        Server for the first time, this is a good way to get one up and running in your environment
        quickly.

      ## Antes de Iniciar
Role required: admin
                  
                     
                  
               
      
      ## Por Que e Quando Desempenhar Esta Tarefa
You are guided through a series of configuration activities that create a fully
            qualified MID Server. A progress indicator on each screen allows you to monitor your
            progress on each task.Each configuration activity provides the following resources to
                help you:
               Contextual embedded help.
               Links to comprehensive documentation on the ServiceNow product documentation
                        site.
            
            Importante: You must complete MID Server configuration before you
                    can launch any other IT Operations Management guided setup.
      
      ## Procedimento

            Navigate to All > Guided Setup > ITOM Guided Setup.
            The IT Operations Management Guided Setup welcome screen appears.
         
            Take one of the following actions:
            
               
                  If none of the MID Server installation and configuration tasks are
                            complete, click Get Started.
                  If you have completed any of the MID Server installation and
                            configuration tasks, click Continue to return to
                            the task list.
                  Select the MID Server icon in the progress bar on the left side of the
                            category screen to display the MID Server category pane at any time.Figura 1. Continuing MID Server guided setup from the progress
                                    bar
                        
                        
                     
               
            
         
            Click Continue.
            The IT Operations Management Guided Setup category screen appears. The
                    controls for starting the MID Server tasks are at the top of the list. These
                    task must be completed before you can set up the other applications that rely on
                    the MID Server.
                     
                  
            
         
            In the MID Server pane, click Get Started.
            The MID Server task list appears with a description of each task.  
                     
                  
            
         
            Click Configure to create the MID Server user and follow
                    the instructions in the help pane that appears on the right side of the screen.
            
               Importante: If you configured MID Servers manually prior to starting
                        Guided Setup, select from that information to complete each specific
                        task.
            
         
            When you have provided the requested information for the MID Server user, click
                        Submit, and then click Mark as
                        Complete at the bottom of the help pane.
            The view returns to the task list. Notice that the circular progress indicator
                    for the category shows 33% of the MID Server configuration complete. The
                    progress indicator on the left side of the screen shows the completion
                    percentage for all the IT Operations Management tasks. 
                     
                  
            
         
            Click Configure for the next task, Download
                    & Install MID.
            
               Java 21.0.7 is bundled with the MID Server installer package and is installed on the host for all new MID Servers. The installer automatically configures Java 21.0.7 to run in your environment. No additional configuration is required. This version supports both 64-bit Windows
               MID Servers and 64-bit Linux
               MID Servers. The MID Server requires a minimum JRE version 17.0.10, and recommended version 21.0.7. If you are using a lower version than 17.0.10, you may see encryption related issues. 

            
         
            Validate your new MID Server.
         
      ## O que Fazer Depois

         If necessary, deploy
                    multiple MID Servers from a single host in your network. Otherwise,
                proceed to configure your MID
                    Server.

---
