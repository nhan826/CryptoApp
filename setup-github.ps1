#!/usr/bin/env powershell
# GitHub Setup Script for CryptoApp
# This script automates the GitHub repository initialization

Write-Host "=== CryptoApp GitHub Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if Git is installed
Write-Host "Checking for Git installation..." -ForegroundColor Yellow
$gitVersion = git --version 2>$null
if (-not $gitVersion) {
    Write-Host "ERROR: Git is not installed!" -ForegroundColor Red
    Write-Host "Please install Git from: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green

# Get repository URL
Write-Host ""
Write-Host "Enter your GitHub repository URL" -ForegroundColor Yellow
Write-Host "Example: https://github.com/YOUR_USERNAME/CryptoApp.git" -ForegroundColor Gray
$repoUrl = Read-Host "Repository URL"

if (-not $repoUrl) {
    Write-Host "ERROR: Repository URL is required" -ForegroundColor Red
    exit 1
}

# Get user info
Write-Host ""
Write-Host "Enter your Git configuration" -ForegroundColor Yellow
$gitName = Read-Host "Your Name"
$gitEmail = Read-Host "Your Email"

if (-not $gitName -or -not $gitEmail) {
    Write-Host "ERROR: Name and email are required" -ForegroundColor Red
    exit 1
}

# Initialize repository
Write-Host ""
Write-Host "Initializing Git repository..." -ForegroundColor Yellow
git init
git config user.name "$gitName"
git config user.email "$gitEmail"

# Add all files
Write-Host "Adding files to repository..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: Lockstitch library and Mac build setup"

# Add remote
Write-Host "Adding remote repository..." -ForegroundColor Yellow
git remote add origin "$repoUrl"

# Create main branch and push
Write-Host "Creating main branch and pushing..." -ForegroundColor Yellow
git branch -M main

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Push to GitHub:"
Write-Host "   git push -u origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Go to GitHub and enable Actions if needed"
Write-Host "3. Watch the build in Actions tab"
Write-Host ""
Write-Host "To push now, run:" -ForegroundColor Yellow
Write-Host "git push -u origin main" -ForegroundColor Gray
