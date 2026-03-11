# ============================================================
# SOC Lab - Case 4: Account Manipulation Simulation
# Generates: Event ID 4723, 4724, 4725, 4726
# MITRE: T1531, T1098
# Run as: Administrator
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SOC Lab - Case 4: Account Manipulation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$targetUser = "target_u"

# ── Setup: Create target account first ────────────────────────
Write-Host "[*] Setup: Creating target account '$targetUser'..." -ForegroundColor Yellow

$initPass = ConvertTo-SecureString "InitPass123!" -AsPlainText -Force

try {
    New-LocalUser -Name $targetUser `
                  -Password $initPass `
                  -PasswordNeverExpires `
                  -ErrorAction Stop | Out-Null
    Write-Host "[+] Target account created: $targetUser" -ForegroundColor Green
} catch {
    Write-Host "[!] Account may already exist, continuing..." -ForegroundColor Yellow
}

Start-Sleep -Seconds 2

# ── Step 1: Attempt password change (Event 4723) ──────────────
Write-Host "[*] Step 1: Attempting password change (4723)..." -ForegroundColor Yellow

# 4723 = user attempts to change own password via ADSI
try {
    $user = [adsi]"WinNT://./$targetUser,user"
    $user.ChangePassword("WrongOldPass!", "NewPass456!")
} catch {
    # Expected to fail — still generates 4723
}
Write-Host "[+] Event 4723 generated - Password change attempted on $targetUser" -ForegroundColor Green

Start-Sleep -Seconds 2

# ── Step 2: Admin force reset password (Event 4724) ───────────
Write-Host "[*] Step 2: Admin force-resetting password (4724)..." -ForegroundColor Yellow

try {
    $newPass = ConvertTo-SecureString "ForcedPass789!" -AsPlainText -Force
    Set-LocalUser -Name $targetUser -Password $newPass -ErrorAction Stop
    Write-Host "[+] Event 4724 generated - Password force-reset on $targetUser" -ForegroundColor Green
} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# ── Step 3: Disable account (Event 4725) ──────────────────────
Write-Host "[*] Step 3: Disabling account (4725)..." -ForegroundColor Yellow

try {
    Disable-LocalUser -Name $targetUser -ErrorAction Stop
    Write-Host "[+] Event 4725 generated - Account disabled: $targetUser" -ForegroundColor Green
} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 2

# ── Step 4: Delete account (Event 4726) ───────────────────────
Write-Host "[*] Step 4: Deleting account (4726)..." -ForegroundColor Yellow

try {
    Remove-LocalUser -Name $targetUser -ErrorAction Stop
    Write-Host "[+] Event 4726 generated - Account deleted: $targetUser" -ForegroundColor Green
} catch {
    Write-Host "[!] Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Case 4 Complete" -ForegroundColor Cyan
Write-Host " Events generated: 4723, 4724, 4725, 4726" -ForegroundColor Cyan
Write-Host " Check: Event Viewer > Security Log" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
