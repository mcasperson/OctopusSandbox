include chocolatey

# We want to run Jenkins in development mode, skipping the initial wizard
# https://wiki.jenkins.io/display/JENKINS/Features+controlled+by+system+properties
windows_env { 'JENKINS_JAVA_OPTIONS':
  ensure    => present,
  mergemode => clobber,
  value     => '-Djenkins.install.runSetupWizard=false'
}

file { 'C:/packages':
    ensure => 'directory',
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

