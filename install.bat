msiexec /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-x64-latest.msi PUPPET_MASTER_SERVER=puppet
call "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" module install puppetlabs/windows
call "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" --disable_warnings=deprecations apply C:\Users\WDAGUtilityAccount\Desktop\OctopusSandbox\octopus.pp