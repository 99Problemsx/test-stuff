# 🤖 CI/CD Pipeline

Complete documentation of our automated GitHub Actions workflows.

---

## 📊 Overview

This project uses **17+ GitHub Actions workflows** for complete automation:

- ✅ **Continuous Integration** - Tests on every commit
- 🚀 **Continuous Deployment** - Auto-releases on tags
- 🔒 **Security** - Automated scanning
- 📚 **Documentation** - Auto-generated docs
- 🤖 **Maintenance** - Automated updates

---

## 🔄 Workflow Categories

### 🚀 Release & Deployment

#### Create Release
**File**: `create-release.yml`  
**Triggers**: Tag push (`v*`)

**What it does**:
1. Packages entire project into ZIP
2. Creates GitHub Release
3. Uploads ZIP as asset
4. Generates release notes from commits

**Usage**:
```bash
git tag v1.0.5
git push origin v1.0.5
```

#### Deploy GitHub Pages
**File**: `deploy-pages.yml`  
**Triggers**: Push to main, Manual

**What it does**:
1. Builds HTML documentation
2. Deploys to GitHub Pages
3. Updates live site: https://99problemsx.github.io/test-stuff/

#### Semantic Release
**File**: `semantic-release.yml`  
**Triggers**: Push to main

**What it does**:
- Automatically bumps version based on commits:
  - `fix:` → v1.0.X (Patch)
  - `feat:` → v1.X.0 (Minor)
  - `BREAKING CHANGE:` → vX.0.0 (Major)

---

### ✅ Quality Assurance

#### Ruby Syntax Check
**File**: `ruby-syntax-check.yml`  
**Triggers**: Push/PR to Plugins/**

**What it does**:
```bash
ruby -c Plugins/**/*.rb
```
- Checks all Ruby files for syntax errors
- Fails build if errors found

#### Code Quality Analysis
**File**: `code-quality.yml`  
**Triggers**: Weekly (Monday), Manual

**Tools**:
- **RuboCop**: Style checking
- **Flog**: Complexity analysis
- **Flay**: Duplication detection

**Artifacts**:
- `rubocop-report.json`
- `flog-report.txt`
- `flay-report.txt`
- `code-stats.md`

#### Validate PBS Files
**File**: `validate-pbs.yml`  
**Triggers**: Push/PR to PBS/**

**Checks**:
- UTF-8 encoding
- BOM (Byte Order Mark)
- Syntax validation

#### Test Plugins
**File**: `test-plugins.yml`  
**Triggers**: Push/PR, Manual

**What it does**:
- Tests plugin load order
- Checks for conflicts
- Validates dependencies

#### Performance Test
**File**: `performance-test.yml`  
**Triggers**: Push to main, Manual

**What it does**:
- Benchmarks critical functions
- Compares against baseline
- Reports performance regressions

---

### 🔒 Security & Maintenance

#### Security Scan
**File**: `security-scan.yml`  
**Triggers**: Push/PR, Weekly, Manual

**Tools**:
- **Trivy**: Vulnerability scanner
- **TruffleHog**: Secret detection

**Features**:
- SARIF upload to GitHub Security
- Checks for hardcoded secrets
- Scans dependencies

#### Dependabot Auto-Merge
**File**: `dependabot-auto-merge.yml`  
**Triggers**: Dependabot PR

**Behavior**:
- **Auto-approves** all Dependabot PRs
- **Auto-merges** Patch (v1.0.X) and Minor (v1.X.0) updates
- **Requires manual review** for Major (vX.0.0) updates

**Setup**:
```yaml
# .github/dependabot.yml (already configured)
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

#### Backup Project
**File**: `backup.yml`  
**Triggers**: Weekly (Sunday 00:00 UTC), Manual

**What it does**:
1. Creates ZIP of entire project
2. Uploads as artifact
3. Keeps for 90 days

**Manual trigger**:
```
Actions → Backup Project → Run workflow
```

#### Stale Bot
**File**: `stale.yml`  
**Triggers**: Daily

**Behavior**:
- After **60 days** of inactivity → adds "stale" label
- After **7 more days** → closes issue/PR
- Activity removes "stale" label

---

### 📚 Documentation

#### Generate Documentation
**File**: `generate-docs.yml`  
**Triggers**: Push to main, Manual

**Generates**:
- `PLUGINS.md` - Plugin inventory
- `PBS_DOCS.md` - PBS file documentation
- `PROJECT_OVERVIEW.md` - Project statistics

#### Update Changelog
**File**: `update-changelog.yml`  
**Triggers**: Push to main, Manual

**What it does**:
- Generates `CHANGELOG_AUTO.md` from git history
- Groups by conventional commit types
- Links to commits and PRs

#### Track Downloads
**File**: `track-downloads.yml`  
**Triggers**: Daily (00:00 UTC), Manual

**What it does**:
- Fetches download counts for all releases
- Updates `STATS.md`
- Shows download trends

---

### 🔔 Notifications

#### Discord Notifications
**File**: `discord-notifications.yml`  
**Triggers**: Push, Release, PR

**Sends webhook to Discord with**:
- Commit information
- Build status
- Release announcements

**Setup**:
```bash
# 1. Create Discord Webhook (Server Settings → Integrations)
# 2. Add as GitHub Secret:
gh secret set DISCORD_WEBHOOK --body "https://discord.com/api/webhooks/..."
```

---

### 🏷️ Automation

#### Auto Label Issues
**File**: `auto-label.yml`  
**Triggers**: PR opened/edited

**Labels PRs based on**:
- Changed file paths (see `.github/labeler.yml`)
- Examples:
  - `.github/workflows/**` → `ci/cd`
  - `PBS/**` → `game-data`
  - `Plugins/**` → `plugins`
  - `*.md` → `documentation`

---

## 🎯 Workflow Statistics

| Metric | Count |
|--------|-------|
| **Total Workflows** | 17 |
| **Automatic** | 14 (82%) |
| **Manual Trigger** | 15 (88%) |
| **Scheduled** | 4 (24%) |
| **Security** | 3 |
| **Quality** | 5 |

---

## 🔧 Manual Workflow Triggers

All workflows with `workflow_dispatch` can be triggered manually:

1. Go to **Actions** tab
2. Select workflow from sidebar
3. Click **"Run workflow"**
4. Select branch (usually `main`)
5. Click **"Run workflow"** button

---

## 📊 Status Badges

Add workflow badges to README:

```markdown
![Workflow Name](https://github.com/99Problemsx/test-stuff/actions/workflows/FILENAME.yml/badge.svg)
```

Example:
```markdown
![Security Scan](https://github.com/99Problemsx/test-stuff/actions/workflows/security-scan.yml/badge.svg)
```

---

## ⚙️ Configuration Files

### Main Workflow Directory
```
.github/
├── workflows/          # All workflow files
│   ├── auto-label.yml
│   ├── backup.yml
│   ├── code-quality.yml
│   ├── create-release.yml
│   ├── deploy-pages.yml
│   ├── discord-notifications.yml
│   ├── generate-docs.yml
│   ├── performance-test.yml
│   ├── ruby-syntax-check.yml
│   ├── security-scan.yml
│   ├── semantic-release.yml
│   ├── stale.yml
│   ├── test-plugins.yml
│   ├── track-downloads.yml
│   ├── update-changelog.yml
│   ├── validate-pbs.yml
│   └── dependabot-auto-merge.yml
├── dependabot.yml      # Dependabot config
└── labeler.yml         # Auto-label config
```

### Secrets Required

| Secret | Used By | Required |
|--------|---------|----------|
| `GITHUB_TOKEN` | All workflows | ✅ Auto-provided |
| `DISCORD_WEBHOOK` | Discord notifications | ❌ Optional |

---

## 🚦 Workflow Status

Check all workflows: **[Actions Tab](https://github.com/99Problemsx/test-stuff/actions)**

### Recent Runs
```bash
# View recent workflow runs
gh run list --limit 10

# View specific workflow
gh run view RUN_ID

# Watch workflow live
gh run watch
```

---

## 🔍 Debugging Workflows

### View Logs
```bash
# Download logs for a run
gh run download RUN_ID

# View failed step logs
gh run view RUN_ID --log-failed
```

### Re-run Failed Jobs
```bash
gh run rerun RUN_ID
```

---

## 📈 Best Practices

### Commit Messages
Use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Add new battle mechanic
fix: Correct Pokemon sprite alignment
docs: Update installation guide
chore: Update dependencies
test: Add plugin tests
ci: Improve workflow performance
```

### Branch Strategy
- `main` - Production-ready code
- `feature/*` - New features
- `fix/*` - Bug fixes
- `docs/*` - Documentation

### Pull Requests
- All PRs trigger workflows
- Required checks must pass
- Auto-labeled by changed files
- Dependabot PRs auto-merge (if allowed)

---

## 🆘 Troubleshooting

### Workflow Fails

1. **Check the logs**: Actions → Failed workflow → Click on red X
2. **Common issues**:
   - Syntax errors in YAML
   - Missing secrets
   - Permission issues
   - Dependency conflicts

### Re-trigger Workflow

```bash
# Re-run a workflow
gh workflow run WORKFLOW_NAME.yml

# Re-run with specific branch
gh workflow run WORKFLOW_NAME.yml --ref BRANCH_NAME
```

### Disable Workflow

Add to workflow file:
```yaml
on:
  workflow_dispatch:  # Manual only
```

Or rename file to `*.yml.disabled`

---

## 📚 Additional Resources

- **[GitHub Actions Docs](https://docs.github.com/en/actions)**
- **[Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)**
- **[WORKFLOWS.md](../WORKFLOWS.md)** - Detailed workflow reference

---

[⬅ Back to Home](Home) | [➡ Next: Contributing](Contributing)
