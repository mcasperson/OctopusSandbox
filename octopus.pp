include chocolatey

# We want to run Jenkins in development mode, skipping the initial wizard
# https://wiki.jenkins.io/display/JENKINS/Features+controlled+by+system+properties
windows_env { 'JENKINS_JAVA_OPTIONS':
  ensure    => present,
  mergemode => clobber,
  value     => '-Djenkins.install.runSetupWizard=false'
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


file { 'C:/program Files (x86)/Jenkins/init.groovy.d':
  ensure => 'directory',
}

file { 'C:/program Files (x86)/Jenkins/init.groovy.d/security.groovy':
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

file { 'C:/program Files (x86)/Jenkins/init.groovy.d/setup.groovy':
  ensure  => 'file',
  owner   => 'Administrators',
  group   => 'Administrators',
  mode    => '0644',
  content => @(EOT)
    #!groovy

    import jenkins.model.*
    import hudson.util.*;
    import jenkins.install.*;

    def instance = Jenkins.getInstance()

    instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
    | EOT
}
