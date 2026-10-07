$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\infra\terraform"

terraform init -input=false | Out-Null
terraform apply -auto-approve -input=false -var="desired_state=running"
terraform apply -refresh-only -auto-approve -input=false -var="desired_state=running" | Out-Null

$ip = terraform output -raw public_ip
Write-Host "`nEC2 is running at $ip. Waiting for Jenkins to come up..." -ForegroundColor Cyan

$ready = $false
for ($i = 0; $i -lt 40; $i++) {
    try {
        $r = Invoke-WebRequest "http://${ip}:8080/login" -UseBasicParsing -TimeoutSec 5
        if ($r.StatusCode -eq 200) { $ready = $true; break }
    } catch { }
    Start-Sleep -Seconds 10
}

if ($ready) {
    Write-Host "`nREADY" -ForegroundColor Green
    Write-Host "Jenkins : http://${ip}:8080"
    Write-Host "App     : http://${ip}:30080"
    Write-Host "Webhook : updated automatically by the server at boot"
} else {
    Write-Host "Jenkins not reachable yet. Wait 2 more minutes and open http://${ip}:8080" -ForegroundColor Yellow
}