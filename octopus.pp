include chocolatey

package { 'jenkins':
  ensure   => installed,
  provider => chocolatey
}

package { 'terraform':
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

/*
package { 'dotnetcore-sdk':
  ensure   => installed,
  provider => chocolatey
}

package { 'nodejs':
  ensure   => installed,
  provider => chocolatey
}

package { 'docker-desktop':
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

file { 'C:/program Files (x86)/Jenkins/init.groovy.d':
  ensure    => 'directory',
  subscribe => Package['jenkins'],
}

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/security.groovy':
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

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/plugins.groovy':
  ensure    => 'file',
  subscribe => File['C:/Program Files (x86)/Jenkins/init.groovy.d/security.groovy'],
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
        "git", "github", "blueocean", "custom-tools-plugin"
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

file_line { 'installStateName':
  subscribe => File['C:/Program Files (x86)/Jenkins/init.groovy.d/plugins.groovy'],
  path      => 'C:/Program Files (x86)/Jenkins/config.xml',
  line      => '  <installStateName>RUNNING</installStateName>',
  match     => '^\s*<installStateName>NEW</installStateName>',
  replace   => true,
}

exec { 'Restart Jenkins':
  subscribe => File_line['installStateName'],
  command   => 'C:\\Windows\\system32\\cmd.exe /c net stop Jenkins & net start Jenkins',
}
