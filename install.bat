@echo This script will populate the Windows Sandbox with a complete Octopus CI/CD environment
@echo It can take a few minutes to complete as a number of application must be downloaded and installed
@echo Please wait until the script has completed before running the applications
@echo A message will be printed when the script has completed

msiexec /qn /norestart /i https://downloads.puppetlabs.com/windows/puppet5/puppet-agent-x64-latest.msi PUPPET_MASTER_SERVER=puppet
call "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" module install puppetlabs/windows
call "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat" apply C:\Users\WDAGUtilityAccount\Desktop\OctopusSandbox\octopus.pp --disable_warnings=deprecations

@echo The script has completed!