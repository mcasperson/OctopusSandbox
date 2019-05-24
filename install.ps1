Invoke-WebRequest -Uri https://raw.githubusercontent.com/mcasperson/OctopusSandbox/master/octopus.pp -OutFile octopus.pp
Start-Process msiexec.exe -Wait -ArgumentList '/qn /norestart /i https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-x64-latest.msi PUPPET_MASTER_SERVER=puppet'
& "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" module install puppetlabs/windows
& "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" apply octopus.pp --disable_warnings=deprecations