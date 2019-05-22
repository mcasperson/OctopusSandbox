file { 'C:/install':
    ensure => 'directory',
}

file { 'octopus':
    ensure => 'file',
    path   => 'C:/install/Octopus.msi',
    mode   => '0660',
    source => 'https://download.octopusdeploy.com/octopus/Octopus.2019.5.4-x64.msi',
}

package { 'Octopus Deploy Server':
    ensure          => installed,
    source          => 'C:/install/Octopus.msi',
    install_options => ['/quiet', 'RUNMANAGERONEXIT=no']
}
