# Quick Start Guide - Get Mac App Built & Tested

## 🚀 The Fast Track (5 Minutes)

### Step 1: Create GitHub Account (2 min)
Go to https://github.com/signup and create a free account

### Step 2: Create Repository (1 min)
1. Go to https://github.com/new
2. Name it `CryptoApp`
3. Click **Create repository**
4. Copy the URL (looks like `https://github.com/YourName/CryptoApp.git`)

### Step 3: Run Setup Script (2 min)
```powershell
cd "C:\Users\natha\OneDrive\Desktop\CryptoApp"
powershell -ExecutionPolicy Bypass -File setup-github.ps1
```

Answer the prompts:
- **Repository URL**: Paste the URL you copied
- **Your Name**: Your full name
- **Your Email**: Your email

### Step 4: Push to GitHub (1 min)
```powershell
git push -u origin main
```

### Step 5: Watch Build (15-20 min)
1. Go to: https://github.com/YourName/CryptoApp
2. Click **Actions** tab
3. Wait for green ✓ checkmark

### Step 6: Download & Test (5 min)
1. Click the completed workflow run
2. Scroll to **Artifacts**
3. Download `CryptoApp-macOS-project`
4. Extract and open in Xcode on a Mac

---

## 📦 What You Get

### From GitHub Actions:
- ✅ **liblockstitch.a** - Compiled library (universal binary)
- ✅ **liblockstitch.dylib** - Shared library
- ✅ **Complete Xcode project** - Ready to build and test
- ✅ **ViewController.swift** - Working UI with encryption

### Ready to:
- ✅ Run on any Mac
- ✅ Distribute to users
- ✅ Integrate into bigger apps
- ✅ Submit to App Store (with modifications)

---

## 🔄 Your Development Cycle (After Setup)

```
Edit Code (Windows)
    ↓
git add . && git commit -m "Your message"
    ↓
git push origin main
    ↓
GitHub Actions Builds (Auto on Mac)
    ↓
Download Artifact
    ↓
Test on Mac
    ↓
Repeat!
```

---

## 🐛 Troubleshooting

### "Setup script won't run"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
powershell -ExecutionPolicy Bypass -File setup-github.ps1
```

### "Git not found"
- Install from: https://git-scm.com/download/win
- Restart PowerShell after install

### "Authentication failed"
1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Click "Generate new token"
3. Select `repo` checkbox
4. Copy the token
5. When prompted for password, paste the token

### Build failed on GitHub?
1. Go to Actions tab
2. Click the failed run
3. Look at the build logs
4. Common issues:
   - File paths wrong in CMakeLists.txt
   - Missing source files
   - Syntax errors in code
5. Fix locally and push again

---

## 📚 More Information

- **Full Setup Guide**: Read `GITHUB_SETUP.md`
- **Mac Build Instructions**: Read `Claudo/lockstitch_files/MAC_BUILD_INSTRUCTIONS.md`
- **GitHub Actions Docs**: https://docs.github.com/en/actions

---

## ✅ Checklist

- [ ] GitHub account created
- [ ] Repository created on GitHub
- [ ] `setup-github.ps1` script run
- [ ] Code pushed: `git push -u origin main`
- [ ] Actions tab shows build in progress
- [ ] Build completed successfully
- [ ] Artifacts downloaded
- [ ] Tested on Mac
- [ ] Ready for production!

---

## 🎯 Next Steps After First Build

1. **Test the app on Mac**
   - Download `CryptoApp-macOS-project`
   - Open in Xcode
   - Test encryption/decryption

2. **Create releases for users**
   - Tag a version: `git tag -a v1.0.0 -m "Release 1.0.0"`
   - Push tag: `git push origin v1.0.0`
   - GitHub Actions creates a Release with downloads

3. **Share with team**
   - Download the `.app` file
   - Share via email, Dropbox, etc.
   - Users can run directly (no compilation needed)

4. **Continue development**
   - Make code changes on Windows
   - Push to GitHub
   - Automatic build and testing
   - Download and verify

---

**Questions? Read GITHUB_SETUP.md for detailed instructions!**
