include chocolatey

package { 'jenkins':
  ensure   => installed,
  provider => chocolatey
}

package { 'octopusdeploy':
  ensure   => installed,
  provider => chocolatey
}

package { 'octopustools':
  ensure   => installed,
  provider => chocolatey
}

package { 'octopusdeploy.tentacle':
  ensure   => installed,
  provider => chocolatey
}

package { '7zip':
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

package { 'docker-desktop':
  ensure   => installed,
  provider => chocolatey
}

/*
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

# CONFIGURE JENKINS

file { 'C:/program Files (x86)/Jenkins/init.groovy.d':
  ensure    => 'directory',
  subscribe => Package['jenkins'],
}

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/1.security.groovy':
  ensure    => 'file',
  subscribe => File['C:/program Files (x86)/Jenkins/init.groovy.d'],
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

    logger.log(Level.INFO, "Creating local admin user 'admin'.")

    def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
    strategy.setAllowAnonymousRead(false)

    def hudsonRealm = new HudsonPrivateSecurityRealm(false)
    hudsonRealm.createAccount("admin", "Password01!")

    instance.setSecurityRealm(hudsonRealm)
    instance.setAuthorizationStrategy(strategy)
    instance.save()

    | EOT
}

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/2.plugins.groovy':
  ensure    => 'file',
  subscribe => File['C:/Program Files (x86)/Jenkins/init.groovy.d/1.security.groovy'],
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import hudson.model.UpdateSite
    import hudson.PluginWrapper
    import jenkins.model.*

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

    // The list of plugins to install
    Set<String> plugins_to_install = [
        "git", "github", "blueocean", "custom-tools-plugin", "simple-theme-plugin"
    ]

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

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/3.simpletheme.groovy':
  ensure    => 'file',
  subscribe => File['C:/Program Files (x86)/Jenkins/init.groovy.d/2.plugins.groovy'],
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    #!groovy
    import jenkins.model.Jenkins;
    import org.jenkinsci.plugins.simpletheme.CssUrlThemeElement;

    Jenkins jenkins = Jenkins.get()

    def themeDecorator = jenkins.getExtensionList(org.codefirst.SimpleThemeDecorator.class).first()

    themeDecorator.setElements([
      new CssUrlThemeElement('https://cdn.rawgit.com/afonsof/jenkins-material-theme/gh-pages/dist/material-blue.css')
    ])

    jenkins.save()

    | EOT
}

file_line { 'installStateName':
  subscribe => File['C:/Program Files (x86)/Jenkins/init.groovy.d/3.simpletheme.groovy'],
  path      => 'C:/Program Files (x86)/Jenkins/config.xml',
  line      => '  <installStateName>RUNNING</installStateName>',
  match     => '^\s*<installStateName>NEW</installStateName>',
  replace   => true,
}

exec { 'Restart Jenkins':
  subscribe => File_line['installStateName'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c net stop Jenkins & net start Jenkins',
}

# CONFIGURE OCTOPUS
file { 'C:/install_octopus.bat':
  ensure    => 'file',
  subscribe => Package['octopusdeploy'],
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" create-instance --instance "OctopusServer" --config "C:\Octopus\OctopusServer.config"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" database --instance "OctopusServer" --connectionString "Data Source=(local)\SQLEXPRESS;Initial Catalog=Octopus;Integrated Security=True" --create --grant "NT AUTHORITY\SYSTEM"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" configure --instance "OctopusServer" --upgradeCheck "False" --upgradeCheckWithStatistics "False" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "DESKTOP-JVNRAAG" --usernamePasswordIsEnabled "True"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" service --instance "OctopusServer" --stop
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" admin --instance "OctopusServer" --username "admin" --email "a@a.com" --password "Password01!"
    "C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe" service --instance "OctopusServer" --install --reconfigure --start --dependOn "MSSQL$SQLEXPRESS"
    | EOT
}

/*
exec { 'Install Octopus':
  subscribe => File['C:/install_octopus.bat'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c C:\\install_octopus.bat',
}

exec { 'Create Dev Environment':
  subscribe => Package['octopustools'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c octo create-environment --name=Dev --user=admin --password=Password01! --server=http://localhost',
}

exec { 'Create Test Environment':
  subscribe => Package['octopustools'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c octo create-environment --name=Test --user=admin --password=Password01! --server=http://localhost',
}

exec { 'Create Prod Environment':
  subscribe => Package['octopustools'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c octo create-environment --name=Prod --user=admin --password=Password01! --server=http://localhost',
}
*/

file { 'C:/install_tentacle.bat':
  ensure    => 'file',
  subscribe => Package['octopusdeploy.tentacle'],
  owner     => 'Administrators',
  group     => 'Administrators',
  mode      => '0644',
  content   => @(EOT)
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" new-certificate --instance "Tentacle" --if-blank
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" configure --instance "Tentacle" --reset-trust
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" configure --instance "Tentacle" --app "C:\Octopus\Applications" --port "10933" --noListen "True"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" polling-proxy --instance "Tentacle" --proxyEnable "False" --proxyUsername "" --proxyPassword "" --proxyHost "" --proxyPort ""
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" register-with --instance "Tentacle" --server "http://localhost" --name "WindowsSandbox" --comms-style "TentacleActive" --server-comms-port "10943" --username "admin" --password "Password01!" --space "Default" --environment "Dev" --role "Windows" --policy "Default Machine Policy"
    "C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe" service --instance "Tentacle" --install --stop --start
    | EOT
}

/*
exec { 'Install Tentacle':
  subscribe => File['C:/install_tentacle.bat'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c C:\\install_tentacle.bat',
}
*/
