# Instructions for Creating the lovable-preserve Branch

## Purpose

This document explains how to create and configure the `lovable-preserve` branch to pin the current lovable deployment, allowing you to continue development on `main` without affecting the running lovable instance.

## Current Lovable Deployment State

The current lovable deployment is at commit: **808152c**

This commit represents the state before local development setup was added. Lovable should continue running from this commit or branch to remain unchanged.

## Steps to Create the lovable-preserve Branch

### Option 1: Via GitHub Web Interface (Easiest)

1. Go to https://github.com/craigfelt/oricol-ticket-flow-34e64301
2. Click on the branch dropdown (currently shows "main" or current branch)
3. Type `lovable-preserve` in the search box
4. Click "Create branch: lovable-preserve from 'main'"
5. Alternatively, use the commit SHA:
   - Go to https://github.com/craigfelt/oricol-ticket-flow-34e64301/commit/808152c
   - Click the `<>` button to browse repository at this commit
   - Use the branch dropdown to create a new branch from this state

### Option 2: Via Git Command Line

If you have push access to the repository:

```bash
# Fetch the latest changes
git fetch origin

# Create the branch at the specific commit
git checkout -b lovable-preserve 808152c

# Push to remote
git push origin lovable-preserve

# Return to your working branch
git checkout copilot/preserve-lovable-deployment
```

### Option 3: Via GitHub CLI

If you have GitHub CLI installed:

```bash
# Create branch from specific commit
gh api repos/craigfelt/oricol-ticket-flow-34e64301/git/refs \
  -f ref='refs/heads/lovable-preserve' \
  -f sha='808152ce9ac0112318366f62812f102f9171e91c'
```

## Configure Lovable to Use the Preserved Branch

Once the `lovable-preserve` branch is created:

1. Log in to your Lovable dashboard
2. Go to project settings or deployment configuration
3. Change the deployment branch from `main` to `lovable-preserve`
4. Save the configuration

Lovable will now deploy from the `lovable-preserve` branch, which is pinned to commit 808152c.

## Alternative: Create a Tag Instead

If you prefer to use a git tag instead of a branch:

```bash
# Create a tag at the specific commit
git tag -a lovable-v1 808152c -m "Lock current lovable deployment"

# Push the tag to remote
git push origin lovable-v1
```

Then configure Lovable to deploy from the `lovable-v1` tag.

## Verify the Setup

After creating the branch/tag and configuring Lovable:

1. Make a small change on the `main` branch
2. Push the change to GitHub
3. Verify that Lovable does NOT automatically deploy the change
4. Verify that Lovable continues running the preserved version

## Benefits

With this setup:

- ✅ Lovable runs from a stable, pinned version (`lovable-preserve` or `lovable-v1`)
- ✅ You can continue development on `main` without affecting lovable
- ✅ You can run a local copy using the override files provided
- ✅ When ready, you can update lovable to point to a new stable branch/tag

## Next Steps

After creating the preserved branch:

1. Continue development on `main` or feature branches
2. Use the local configuration for testing:
   ```bash
   ./switch-config.sh local
   docker compose -f docker-compose.yml -f docker-compose.override.local.yml up -d
   npm run dev
   ```
3. When ready to update lovable, create a new stable branch/tag and update lovable config

## Rollback

If you need to rollback `main` to the preserved state:

```bash
# Merge the preserved state back into main
git checkout main
git merge --no-ff lovable-preserve
git push origin main
```

Or for a hard reset (⚠️ destructive):

```bash
git checkout main
git reset --hard lovable-preserve
git push --force origin main  # Requires force push permission
```

## Support

For questions or issues, refer to:
- [LOVABLE_PRESERVE_GUIDE.md](./LOVABLE_PRESERVE_GUIDE.md) - Complete guide
- Repository issues: https://github.com/craigfelt/oricol-ticket-flow-34e64301/issues
