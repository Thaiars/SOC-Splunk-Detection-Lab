# Suspicious PowerShell Simulation 


auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f

# Simulate encoded PowerShell (reconnaissance commands)
$command = "whoami; hostname; ipconfig"
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command))

Write-Host "Encoded command: $encoded"
Write-Host "Running encoded command..."

powershell.exe -EncodedCommand $encoded
Write-Host "Event 4688 generated!"
