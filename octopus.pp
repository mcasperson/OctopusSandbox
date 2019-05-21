file { 'octopus':
    path => 'C:/install/Octopus.msi',
    ensure => 'file',
    mode => '0660',
    source => 'https://download.octopusdeploy.com/octopus/Octopus.2019.5.4-x64.msi',
}

package { "octopus":
    ensure          => installed,
    source          => 'C:/install/Octopus.msi',
    install_options => ['/quiet', 'RUNMANAGERONEXIT=no']
}
