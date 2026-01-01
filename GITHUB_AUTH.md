# GitHub Authentication Setup (Personal Access Token)

## Why You Need This

GitHub requires authentication when pushing code from your computer. This guide helps you create a **Personal Access Token** to authenticate with GitHub.

---

## Step 1: Create a Personal Access Token

### Go to GitHub Settings:
1. Log into https://github.com
2. Click your **profile icon** (top right)
3. Click **Settings**
4. Scroll down left sidebar to **Developer settings**
5. Click **Personal access tokens**
6. Click **Generate new token**

### Configure the Token:
1. **Note**: Type `CryptoApp-Build` (or any name you remember)
2. **Expiration**: Select **90 days** or **No expiration**
3. **Select scopes**: Check the box for `repo` (Full control of private repositories)
4. Scroll to bottom and click **Generate token**

### Save the Token:
⚠️ **IMPORTANT**: Copy the token immediately - GitHub won't show it again!
```
ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Save it in a safe place (password manager, notepad, etc.)

---

## Step 2: Use the Token When Pushing

When you run this command:
```powershell
git push -u origin main
```

You'll be prompted for credentials:
- **Username**: Your GitHub username
- **Password**: Paste your token (NOT your actual GitHub password)

---

## Step 3: (Optional) Save Token Permanently

### Option A: Git Credential Manager (Easiest)
Windows automatically saves it after first use. Just remember:
- Use your token as the password once
- Git remembers it for future pushes

### Option B: Create .netrc file (Advanced)
Create a file at `C:\Users\natha\.netrc` with:
```
machine github.com
login YOUR_GITHUB_USERNAME
password ghp_your_token_here
```

Then use:
```powershell
git config --global credential.helper store
```

---

## Quick Reference

### Push code (you'll be prompted for token):
```powershell
git push -u origin main
```

### Change your token later:
1. GitHub Settings → Developer settings → Personal access tokens
2. Click the token you created
3. Click **Regenerate token**
4. Copy the new token
5. Update it in Git Credential Manager or .netrc

---

## Troubleshooting

### "Authentication failed"
- Make sure you're using the token as password, NOT your GitHub password
- Token must have `repo` scope enabled
- Token may have expired (create a new one)

### "Keep prompting for password"
- Ensure Git Credential Manager is enabled:
  ```powershell
  git config --global credential.helper manager-core
  ```

### "Can't find Git Credential Manager"
- Update Git: https://git-scm.com/download/win
- Restart PowerShell after update

---

## Security Best Practices

✅ **Do:**
- Store token in password manager
- Use short expiration (90 days) and regenerate
- Only give `repo` scope
- Delete unused tokens

❌ **Don't:**
- Commit token to GitHub (it will be visible!)
- Share token in emails or messages
- Use your actual GitHub password
- Post token in forums or chat

---

## Next Steps

After creating your token:
```powershell
cd "C:\Users\natha\OneDrive\Desktop\CryptoApp"
git remote add origin https://github.com/YOUR_USERNAME/CryptoApp.git
git push -u origin main
```

Then paste your token when prompted!
