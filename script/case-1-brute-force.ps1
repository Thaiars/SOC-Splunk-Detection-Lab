# Brute Force Simulation 
auditpol /set /subcategory:"Logon" /failure:enable

# Simulate 10 failed login attempts
$targetUsers = @("FakeUser1","FakeUser2","FakeUser3","FakeUser4","FakeUser5",
                 "FakeUser6","FakeUser7","FakeUser8","FakeUser9","FakeUser10")

$attempts = 0
foreach ($user in $targetUsers) {
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $ctx = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
        [System.DirectoryServices.AccountManagement.ContextType]::Machine,
        $env:COMPUTERNAME
    )
    $ctx.ValidateCredentials($user, "wrongpassword123")
    $attempts++
    Write-Host "[$attempts] Failed login attempt: $user"
    Start-Sleep -Milliseconds 800
}

Write-Host "$attempts failed attempts generated."
