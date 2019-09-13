include chocolatey

package { '7zip':
  ensure   => installed,
  provider => chocolatey
}

package { 'jenkins':
  ensure   => installed,
  provider => chocolatey
}

package { 'git':
  ensure   => installed,
  provider => chocolatey
}

package { 'notepadplusplus':
  ensure   => installed,
  provider => chocolatey
}

package { 'terraform':
  ensure   => installed,
  provider => chocolatey
}

package { 'microsoft-build-tools':
  ensure   => installed,
  provider => chocolatey
}

package { 'jre8':
  ensure   => installed,
  provider => chocolatey
}

package { 'googlechrome':
  ensure   => installed,
  provider => chocolatey
}

/*
package { 'docker-desktop':
  ensure   => installed,
  provider => chocolatey
}

package { 'docker-cli':
  ensure   => installed,
  provider => chocolatey
}

package { 'dotnetcore-sdk':
  ensure   => installed,
  provider => chocolatey
}

package { 'nodejs':
  ensure   => installed,
  provider => chocolatey
}

package { 'kubernetes-helm':
  ensure   => installed,
  provider => chocolatey
}

package { 'kubernetes-cli':
  ensure   => installed,
  provider => chocolatey
}

package { 'minikube':
  ensure   => installed,
  provider => chocolatey
}

package { 'awscli':
  ensure   => installed,
  provider => chocolatey
}
*/

# DOWNLOAD DEPENDENCIES

windows_env { 'PATH=C:\tools': }

file { 'C:/tools':
  ensure => 'directory'
}

archive { 'C:/tools/chromedriver_win32.zip':
  ensure       => present,
  extract      => true,
  extract_path => 'C:/tools',
  source       => 'https://chromedriver.storage.googleapis.com/77.0.3865.40/chromedriver_win32.zip',
  creates      => 'C:/tools/chromedriver.exe',
  cleanup      => true,
}

file { 'C:/install':
  ensure => 'directory'
}

file { 'C:/install/octopus.client.6.7.0':
  ensure => 'directory'
}
-> archive { 'C:/install/Octopus.Client.nupkg':
  ensure       => present,
  extract      => true,
  extract_path => 'C:/install/octopus.client.6.7.0',
  source       => 'https://www.nuget.org/api/v2/package/Octopus.Client/6.7.0',
  creates      => 'C:/install/octopus.client.6.7.0/Octopus.Client.nuspec',
  cleanup      => true,
}

file { 'C:/install/newtonsoft.json.9.0.1':
  ensure => 'directory'
}
-> archive { 'C:/install/Newtonsoft.Json.nupkg':
  ensure       => present,
  extract      => true,
  extract_path => 'C:/install/newtonsoft.json.9.0.1',
  source       => 'https://www.nuget.org/api/v2/package/Newtonsoft.Json/9.0.1',
  creates      => 'C:/install/newtonsoft.json.9.0.1/Newtonsoft.Json.nuspec',
  cleanup      => true,
}

file { 'C:/install/system.componentmodel.annotations.4.1.0':
  ensure => 'directory'
}
-> archive { 'C:/install/System.ComponentModel.Annotations.nupkg':
  ensure       => present,
  extract      => true,
  extract_path => 'C:/install/system.componentmodel.annotations.4.1.0',
  source       => 'https://www.nuget.org/api/v2/package/System.ComponentModel.Annotations/4.1.0',
  creates      => 'C:/install/system.componentmodel.annotations.4.1.0/System.ComponentModel.Annotations.nuspec',
  cleanup      => true,
}

# CONFIGURE OCTOPUS

package { 'sql-server-express':
  ensure   => installed,
  provider => chocolatey
}
-> package { 'octopusdeploy':
  ensure   => installed,
  provider => chocolatey
}
-> file { 'C:/install_octopus.bat':
  ensure  => 'file',
  owner   => 'Administrators',
  group   => 'Administrators',
  mode    => '0644',
  content => @(EOT)
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" create-instance --instance "OctopusServer" --config "C:\Octopus\OctopusServer.config"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" database --instance "OctopusServer" --connectionString "Data Source=(local)\SQLEXPRESS;Initial Catalog=Octopus;Integrated Security=True" --create --grant "NT AUTHORITY\SYSTEM"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" configure --instance "OctopusServer" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "DESKTOP-JVNRAAG" --usernamePasswordIsEnabled "True"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" service --instance "OctopusServer" --stop
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" admin --instance "OctopusServer" --username "admin" --email "a@a.com" --password "Password01!"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" service --instance "OctopusServer" --install --reconfigure --start --dependOn "MSSQL$SQLEXPRESS"
    copy /y NUL C:\OctopusDeployInstalled.txt >NUL
    | EOT
}
-> exec { 'Install Octopus':
  command => 'C:\\Windows\\system32\\cmd.exe /c C:\\install_octopus.bat',
  creates => 'C:/OctopusDeployInstalled.txt',
}
-> package { 'octopustools':
  ensure   => installed,
  provider => chocolatey
}
-> exec{'Create Octopus Shortcut':
    provider => 'powershell',
    command  => '$sh = New-Object -comObject WScript.Shell; $short = $sh.CreateShortcut($sh.SpecialFolders("Desktop") + "\\Octopus.lnk"); $short.TargetPath = "http://localhost"; $short.Save();'
}
-> file { 'C:/initialise_octopus.ps1':
  ensure  => 'file',
  owner   => 'Administrators',
  group   => 'Administrators',
  mode    => '0644',
  content => @(EOT)
    Add-Type -Path "C:/install/system.componentmodel.annotations.4.1.0/lib/netstandard1.4/System.ComponentModel.Annotations.dll"
    Add-Type -Path "C:/install/newtonsoft.json.9.0.1/lib/netstandard1.0/Newtonsoft.Json.dll"
    Add-Type -Path "C:/install/octopus.client.6.7.0/lib/netstandard2.0/Octopus.Client.dll"

    #Creating a connection
    $endpoint = new-object Octopus.Client.OctopusServerEndpoint "http://localhost"
    $repository = new-object Octopus.Client.OctopusRepository $endpoint

    #Creating login object
    $LoginObj = New-Object Octopus.Client.Model.LoginCommand 
    $LoginObj.Username = "admin"
    $LoginObj.Password = "Password01!"

    #Loging in to Octopus
    $repository.Users.SignIn($LoginObj)

    #Getting current user logged in
    $UserObj = $repository.Users.GetCurrent()

    #Creating API Key for user. This automatically gets saved to the database.
    $ApiObj = $repository.Users.CreateApiKey($UserObj, "Puppet Install")

    #Save the API key so we can use it later
    Set-Content -Path c:\octopus_api_key.txt -Value $ApiObj.ApiKey

    #Create the standard environments
    & C:\ProgramData\chocolatey\bin\octo.exe create-environment --name=Dev --apiKey=$($ApiObj.ApiKey) --server=http://localhost --ignoreIfExists
    & C:\ProgramData\chocolatey\bin\octo.exe create-environment --name=Test --apiKey=$($ApiObj.ApiKey) --server=http://localhost --ignoreIfExists
    & C:\ProgramData\chocolatey\bin\octo.exe create-environment --name=Prod --apiKey=$($ApiObj.ApiKey) --server=http://localhost --ignoreIfExists

    Set-Content -Path C:\octopus_api.txt -Value $($ApiObj.ApiKey)
    | EOT
}
-> exec { 'Populate Environments':
  command  => '& C:/initialise_octopus.ps1',
  provider => powershell,
}

package { 'octopusdeploy.tentacle':
  ensure   => installed,
  provider => chocolatey
}
-> file { 'C:/install_tentacle.bat':
  ensure  => 'file',
  owner   => 'Administrators',
  group   => 'Administrators',
  mode    => '0644',
  content => @(EOT)
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" new-certificate --instance "Tentacle" --if-blank
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" configure --instance "Tentacle" --reset-trust
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" configure --instance "Tentacle" --app "C:\Octopus\Applications" --port "10933" --noListen "True"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" polling-proxy --instance "Tentacle" --proxyEnable "False" --proxyUsername "" --proxyPassword "" --proxyHost "" --proxyPort ""
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" register-with --instance "Tentacle" --server "http://localhost" --name "WindowsSandbox" --comms-style "TentacleActive" --server-comms-port "10943" --username "admin" --password "Password01!" --space "Default" --environment "Dev" --role "Windows" --policy "Default Machine Policy"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" service --instance "Tentacle" --install --stop --start
    copy /y NUL C:\OctopusTentacleInstalled.txt >NUL
    | EOT
}
-> exec { 'Install Tentacle':
  command => 'C:\\Windows\\system32\\cmd.exe /c C:\\install_tentacle.bat',
  creates => 'C:/OctopusTentacleInstalled.txt',
}

# CONFIGURE JENKINS

file { 'C:/program Files (x86)/Jenkins/init.groovy.d':
  ensure    => 'directory',
  subscribe => Package['jenkins'],
}
-> file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/a.security.groovy':
  ensure    => 'file',
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import java.util.logging.Level
    import java.util.logging.Logger
    import hudson.security.*
    import jenkins.model.*

    def instance = Jenkins.getInstance()
    def logger = Logger.getLogger(Jenkins.class.getName())
    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    def users = hudsonRealm.getAllUsers().collect { it.toString() }

    if ("jenkinsadmin" in users) {
      logger.log(Level.INFO, "User 'jenkinsadmin' already exists.")
    } else {
      logger.log(Level.INFO, "Creating local admin user 'jenkinsadmin'.")
      hudsonRealm.createAccount("jenkinsadmin", "Password01!")
      def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
      strategy.setAllowAnonymousRead(false)
      instance.setSecurityRealm(hudsonRealm)
      instance.setAuthorizationStrategy(strategy)
      instance.save()
    }

    | EOT
}
-> file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/b.plugins.groovy':
  ensure    => 'file',
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import hudson.model.UpdateSite
    import hudson.PluginWrapper
    import jenkins.model.*

    // The list of plugins to install
    Set<String> plugins_to_install = [
        "git", "github", "blueocean", "custom-tools-plugin", "simple-theme-plugin", "plain-credentials"
    ]

    /*
      Install Jenkins plugins
    */
    def install(Collection c, Boolean dynamicLoad, UpdateSite updateSite) {
        c.each {
            println "Installing ${it} plugin."
            UpdateSite.Plugin plugin = updateSite.getPlugin(it)
            Throwable error = plugin.deploy(dynamicLoad).get().getError()
            if(error != null) {
                println "ERROR installing ${it}, ${error}"
            }
        }
        null
    }

    // Some useful vars to set
    Boolean hasConfigBeenUpdated = false

    // The default update site
    UpdateSite updateSite = Jenkins.getInstance().getUpdateCenter().getById('default')

    List<PluginWrapper> plugins = Jenkins.instance.pluginManager.getPlugins()

    //get a list of installed plugins
    Set<String> installed_plugins = []
    plugins.each {
      installed_plugins << it.getShortName()
    }

    //check to see if there are missing plugins to install
    Set<String> missing_plugins = plugins_to_install - installed_plugins
    if(missing_plugins.size() > 0) {
        println "Install missing plugins..."
        install(missing_plugins, true, updateSite)
        println "Done installing missing plugins."
        hasConfigBeenUpdated = true
    }

    if(hasConfigBeenUpdated) {
        println "Saving Jenkins configuration to disk."
        Jenkins.instance.save()
    } else {
        println "Jenkins up-to-date.  Nothing to do."
    }    

    | EOT
}
-> file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/c.simpletheme.groovy':
  ensure    => 'file',
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import jenkins.model.Jenkins;
    import org.jenkinsci.plugins.simpletheme.CssUrlThemeElement;
    import java.util.logging.Logger;
    import java.util.logging.Level;

    Jenkins jenkins = Jenkins.get()
    def logger = Logger.getLogger(Jenkins.class.getName())
    def themeDecorator = jenkins.getExtensionList(org.codefirst.SimpleThemeDecorator.class).first()

    if (themeDecorator.getElements().stream().anyMatch{it -> it instanceof CssUrlThemeElement}) {
      logger.log(Level.INFO, "Simple theme already has a CSS URL.")      
    } else {
      logger.log(Level.INFO, "Setting simple theme CSS URL.")
      themeDecorator.setElements([
        new CssUrlThemeElement('https://cdn.rawgit.com/afonsof/jenkins-material-theme/gh-pages/dist/material-blue.css')
      ])
      jenkins.save()
    }

    | EOT
}
-> file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/d.secrets.groovy':
  ensure    => 'file',
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import jenkins.model.*
    import com.cloudbees.plugins.credentials.*
    import com.cloudbees.plugins.credentials.common.*
    import com.cloudbees.plugins.credentials.domains.*
    import com.cloudbees.plugins.credentials.impl.*
    import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
    import org.jenkinsci.plugins.plaincredentials.*
    import org.jenkinsci.plugins.plaincredentials.impl.*
    import hudson.util.Secret
    import hudson.plugins.sshslaves.*
    import org.apache.commons.fileupload.* 
    import org.apache.commons.fileupload.disk.*
    import java.nio.file.Files

    domain = Domain.global()
    store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

    store.addCredentials(
      domain, 
      new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "APIKey",
        "Octopus API Key",
        Secret.fromString(new File("C:\\octopus_api.txt").text)))

    store.addCredentials(
      domain, 
      new StringCredentialsImpl(
        CredentialsScope.GLOBAL,
        "OctopusServer",
        "Octopus Server URL",
        Secret.fromString("http://localhost")))

    /*
    priveteKey = new BasicSSHUserPrivateKey(
    CredentialsScope.GLOBAL,
    "jenkins-slave-key",
    "root",
    new BasicSSHUserPrivateKey.UsersPrivateKeySource(),
    "",
    ""
    )

    store.addCredentials(domain, priveteKey)
    */

    /*
    usernameAndPassword = new UsernamePasswordCredentialsImpl(
      CredentialsScope.GLOBAL,
      "jenkins-slave-password", "Jenkis Slave with Password Configuration",
      "root",
      "jenkins"
    )

    store.addCredentials(domain, usernameAndPassword)
    */    

    /*
    factory = new DiskFileItemFactory()
    dfi = factory.createItem("", "application/octet-stream", false, "filename")
    out = dfi.getOutputStream()
    file = new File("/path/to/some/file")
    Files.copy(file.toPath(), out)
    FileCredentailsImpl can take a file from a do
    secretFile = new FileCredentialsImpl(
    CredentialsScope.GLOBAL,
    "secret-file",
    "Secret File Description"
    dfi, // Don't use FileItem
    "",
    "")
    
    store.addCredentials(domain, secretFile)
    */
    | EOT
}
-> file_line { 'installStateName':
  path      => 'C:/Program Files (x86)/Jenkins/config.xml',
  line      => '  <installStateName>RUNNING</installStateName>',
  match     => '^\s*<installStateName>NEW</installStateName>',
  replace   => true,
}
-> exec { 'Restart Jenkins':
  command   => 'C:\\Windows\\system32\\cmd.exe /c net stop Jenkins & net start Jenkins',
}
-> exec{'Create Jenkins Shortcut':
    provider => 'powershell',
    command  => '$sh = New-Object -comObject WScript.Shell; $short = $sh.CreateShortcut($sh.SpecialFolders("Desktop") + "\\Jenkins.lnk"); $short.TargetPath = "http://localhost:8080"; $short.Save();'
}


