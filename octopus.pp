include chocolatey

file { 'C:/program Files (x86)/Jenkins':
  ensure => 'directory',
}

file { 'C:/program Files (x86)/Jenkins/init.groovy.d':
  ensure => 'directory',
}

file { 'C:/Program Files (x86)/Jenkins/init.groovy.d/security.groovy':
  ensure  => 'file',
  owner   => 'Administrators',
  group   => 'Administrators',
  mode    => '0644',
  content => @(EOT)
    #!groovy
    import java.util.logging.Level
    import java.util.logging.Logger
    import hudson.security.*
    import jenkins.model.*

    def instance = Jenkins.getInstance()
    def logger = Logger.getLogger(Jenkins.class.getName())

    logger.log(Level.INFO, "Ensuring that local user 'admin' is created.")

    if (!instance.isUseSecurity()) {
        logger.log(Level.INFO, "Creating local admin user 'admin'.")

        def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
        strategy.setAllowAnonymousRead(false)

        def hudsonRealm = new HudsonPrivateSecurityRealm(false)
        hudsonRealm.createAccount("admin", "Password01!")

        instance.setSecurityRealm(hudsonRealm)
        instance.setAuthorizationStrategy(strategy)
        instance.save()
    }
    | EOT
}

package { '7zip':
  ensure   => installed,
  provider => chocolatey
}

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

augeas{ "bbdisplay_setting":
  incl    => 'C:/Program Files (x86)/Jenkins/config.xml',
  lens    => "Xml.lns",
  changes => "set hudson/installStateName RUNNING",
}
