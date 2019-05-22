include chocolatey

file { 'C:/packages':
    ensure => 'directory',
}

package { '7zip':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

package { 'jenkins':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

package { 'terraform':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

package { 'octopusdeploy':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

package { 'octopustools':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

package { 'octopusdeploy.tentacle':
  ensure   => installed,
  provider => chocolatey,
  source   => 'c:/packages',
}

