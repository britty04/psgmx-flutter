# 🔥 Firebase Hosting Deployment Guide

## 📋 Prerequisites

- Firebase account (free Spark plan)
- Firebase CLI installed
- GitHub repository

## 🚀 Setup Steps

### 1. Install Firebase CLI

```bash
npm install -g firebase-tools
```

### 2. Login to Firebase

```bash
firebase login
```

### 3. Initialize Firebase Project

```bash
# In your project root
firebase init hosting
```

**Configuration:**
- Use existing project or create new one
- Public directory: `build/web`
- Single-page app: `Yes`
- Set up automatic builds: `No` (we use GitHub Actions)
- Don't overwrite files

### 4. Get Firebase Service Account

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Save the JSON file (keep it secret!)

### 5. Add GitHub Secrets

Go to GitHub → Your Repository → Settings → Secrets → Actions

Add these secrets:

```
SUPABASE_URL
Value: https://dsucqgrwyimtuhebvmpx.supabase.co

SUPABASE_ANON_KEY
Value: sb_publishable_0Xf74Qb5kGsF9qvOHL4nAA_m31d69DK

FIREBASE_PROJECT_ID
Value: your-firebase-project-id

FIREBASE_SERVICE_ACCOUNT
Value: (paste entire JSON from step 4)
```

### 6. Update .firebaserc

Edit `.firebaserc` file:

```json
{
  "projects": {
    "default": "your-firebase-project-id"
  }
}
```

## 🎯 Deployment

### Automatic (Recommended)

Every push to `main` branch automatically:
1. Builds Flutter Web
2. Deploys to Firebase Hosting

### Manual Deployment

```bash
# Build Flutter Web
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=SUPABASE_URL=https://dsucqgrwyimtuhebvmpx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_0Xf74Qb5kGsF9qvOHL4nAA_m31d69DK

# Deploy to Firebase
firebase deploy --only hosting
```

## 🌐 Your Live URL

After deployment, your app will be available at:
```
https://your-project-id.web.app
https://your-project-id.firebaseapp.com
```

## 💰 Free Spark Plan Limits

Firebase Hosting (Spark Plan):
- ✅ 10 GB storage
- ✅ 360 MB/day transfer
- ✅ Custom domain support
- ✅ SSL certificates
- ✅ CDN included

More than enough for your app!

## 🔒 Security

Your Supabase keys are:
- ✅ Encrypted in GitHub Secrets
- ✅ Injected at build time
- ✅ Never exposed in repository

## ✅ Verify Deployment

1. Check GitHub Actions tab for build status
2. Visit your Firebase Hosting URL
3. Test login functionality
4. Check browser console for errors

## 🆘 Troubleshooting

**Build fails?**
- Check GitHub Actions logs
- Verify all secrets are set correctly
- Ensure Flutter dependencies are up to date

**Deployment fails?**
- Verify Firebase service account JSON is valid
- Check Firebase project ID matches
- Ensure you have proper permissions

**App shows blank screen?**
- Check browser console (F12)
- Verify Supabase URL and key are correct
- Test on different browsers

## 📱 Custom Domain (Optional)

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow DNS setup instructions
4. Free SSL certificate automatically provisioned

## 🔄 Rollback

To rollback to previous version:

```bash
firebase hosting:clone your-project-id:live your-project-id:live
```

Or use Firebase Console → Hosting → View history → Rollback

---

**Made with ❤️ for PSG MCA Batch 2025-2027**
