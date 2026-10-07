$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\..\infra\terraform"
terraform init -input=false | Out-Null
terraform apply -auto-approve -input=false -var="desired_state=stopped"
Write-Host "`nEC2 stopped. Compute billing paused (only the small disk cost remains)." -ForegroundColor Green