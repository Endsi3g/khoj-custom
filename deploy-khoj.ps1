# Check for Docker
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed. Please install Docker and try again."
    exit 1
}

# Check for Docker Compose
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Error "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
}

Write-Host "Cleaning up any conflicting containers..." -ForegroundColor Gray
# Remove conflicting khoj-computer if it exists (it has a fixed name in docker-compose.yml)
docker rm -f khoj-computer 2>$null

Write-Host "Starting Khoj deployment..." -ForegroundColor Cyan

# Run Docker Compose
docker-compose up -d --remove-orphans

if ($LASTEXITCODE -eq 0) {
    Write-Host "Khoj has been deployed successfully!" -ForegroundColor Green
    Write-Host "Access it at http://localhost:42110" -ForegroundColor Yellow
}
else {
    Write-Error "Failed to deploy Khoj."
}
