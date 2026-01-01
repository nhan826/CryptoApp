# GitHub Setup & Deployment Guide

## Overview
This guide will help you:
1. Set up a GitHub repository for your CryptoApp
2. Enable GitHub Actions to automatically build Mac binaries
3. Download and test the compiled app

## Prerequisites
- A GitHub account (free at https://github.com)
- Git installed on Windows (https://git-scm.com/download/win)
- VS Code or terminal to commit code

---

## Step 1: Create GitHub Repository

### On GitHub.com:
1. Go to https://github.com/new
2. Enter repository name: `CryptoApp` (or your preferred name)
3. Choose **Private** or **Public** (Private recommended for business apps)
4. Click **Create repository**

### Copy the repository URL:
- You'll see something like: `https://github.com/YOUR_USERNAME/CryptoApp.git`
- Save this URL - you'll need it next

---

## Step 2: Initialize Git Locally

### Open PowerShell in your CryptoApp folder:
```powershell
cd "C:\Users\natha\OneDrive\Desktop\CryptoApp"
```

### Initialize Git repository:
```powershell
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
git add .
git commit -m "Initial commit: Lockstitch library and Mac build setup"
```

### Add remote repository (replace with your URL):
```powershell
git remote add origin https://github.com/YOUR_USERNAME/CryptoApp.git
```

### Create main branch and push:
```powershell
git branch -M main
git push -u origin main
```

**Note**: If you get authentication errors:
- Use **Personal Access Token** instead of password:
  1. GitHub Settings → Developer settings → Personal access tokens → Generate new token
  2. Select `repo` scope
  3. Use the token as password when prompted

---

## Step 3: Verify GitHub Actions is Enabled

### On GitHub.com:
1. Go to your repository: `https://github.com/YOUR_USERNAME/CryptoApp`
2. Click **Actions** tab
3. You should see "Build Lockstitch Mac Library & App" workflow
4. If disabled, click **Enable workflows**

---

## Step 4: Make a Commit to Trigger Build

### Edit any file (e.g., add a comment to ViewController.swift):
```powershell
cd "C:\Users\natha\OneDrive\Desktop\CryptoApp"
git add .
git commit -m "Minor update to trigger build"
git push origin main
```

### Watch the build happen:
1. Go to GitHub repository → **Actions** tab
2. You'll see the workflow running
3. Wait ~15-20 minutes for the build to complete
4. Check for green ✓ (success) or red ✗ (failed)

---

## Step 5: Download Build Artifacts

### When build completes successfully:

1. Go to **Actions** tab
2. Click the latest workflow run
3. Scroll down to **Artifacts** section
4. Download:
   - `lockstitch-mac-libraries` (library files)
   - `CryptoApp-macOS-project` (complete project)

### Extract the files:
- Libraries go to your Xcode project's build folder
- Project folder contains everything ready for Xcode

---

## Step 6: Testing the App

### Option A: Manual Testing on Mac
1. Download `CryptoApp-macOS-project.zip`
2. Extract it
3. Open `CryptoApp.xcodeproj` in Xcode
4. Build and run (Cmd + R)

### Option B: Remote Testing
1. Upload the artifact to a Mac machine
2. Extract and open in Xcode
3. Test the encryption/decryption features

### Option C: Share for QA
1. Create a release tag for automatic release creation
2. Precompiled binaries available for download

---

## Step 7: Setting Up Automatic Releases (Optional)

### Tag a release to trigger automatic artifact upload:
```powershell
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```

### Result:
- GitHub Actions creates a Release
- Downloads all artifacts automatically
- Available in Repository → Releases

---

## Continuous Development Workflow

### After initial setup, your workflow is simple:

```
1. Make code changes on Windows
2. Commit: git add . && git commit -m "Your message"
3. Push: git push origin main
4. GitHub Actions automatically builds on Mac
5. Download artifact when done (~15-20 min)
6. Test on Mac
7. Repeat!
```

---

## Troubleshooting

### Build Failed in GitHub Actions?
1. Go to **Actions** tab
2. Click the failed workflow run
3. Scroll down to see build logs
4. Look for error messages (usually linking errors or missing files)
5. Fix on Windows and push again

### Common Issues:

**CMake not found**
- Already installed in macOS runners
- If error persists, check CMakeLists.txt syntax

**Link errors with Lockstitch library**
- Verify file paths in CMakeLists.txt are correct
- Check that Lockstitch.cpp and Lockstitch.h exist

**Authentication errors**
- Use Personal Access Token (see Step 2)
- Make sure token has `repo` scope enabled

---

## File Locations in Workflow

The GitHub Actions workflow expects this structure:
```
CryptoApp/
├── .github/workflows/
│   └── build-mac.yml          (this file)
├── Claudo/
│   ├── code.txt
│   └── lockstitch_files/
│       ├── Lockstitch.cpp
│       ├── Lockstitch.h
│       ├── pch.h
│       ├── pch.cpp
│       ├── framework.h
│       ├── LockstitchWrapper.h
│       ├── LockstitchWrapper.mm
│       ├── ViewController.swift
│       └── CMakeLists.txt
```

If you restructure folders, update the `build-mac.yml` paths accordingly.

---

## Next Steps

1. Create GitHub account if you don't have one
2. Run the PowerShell commands from Step 2
3. Wait for the first build
4. Download artifacts
5. Test on a Mac machine
6. Iterate!

## Questions?

- GitHub Actions Docs: https://docs.github.com/en/actions
- GitHub Help: https://github.com/contact
- CMake Docs: https://cmake.org/documentation/
