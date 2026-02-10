---
name: git-workflow
description: "Git and GitHub lifecycle: quality commits with Conventional Commits, PRs, releases, issues, and GitHub Actions via gh CLI and GitHub MCP. Triggers on: commit, stage changes, split commits, push to GitHub, create PR, create release, create repo, GitHub Actions, tag version, gh."
cli: gh
mcp: github
---

# Git Workflow

End-to-end git and GitHub workflow using `gh` CLI and GitHub MCP.

## Prerequisites

**Install GitHub CLI:**
```bash
# macOS
brew install gh

# Windows
winget install --id GitHub.cli

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh
```

**Authenticate:**
```bash
gh auth login
gh auth status  # verify
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Create repo | `gh repo create [name] --public/--private` |
| Clone repo | `gh repo clone owner/repo` |
| Create PR | `gh pr create --title "..." --body "..."` |
| View/merge PR | `gh pr view 42` / `gh pr merge 42` |
| Create release | `gh release create v1.0.0 --generate-notes` |
| Create issue | `gh issue create --title "..." --body "..."` |
| Close issue | `gh issue close 123` |
| List workflows | `gh workflow list` |
| Trigger workflow | `gh workflow run deploy.yml` |
| Watch run | `gh run watch [run-id]` |

---

## Commit Workflow

Make commits that are easy to review and safe to ship.

### Inputs to ask for (if missing)
- Single or multiple commits? Default to multiple when changes are unrelated.
- Any rules: max subject length, required scopes.

### Steps

1. **Inspect the working tree**
   - `git status` and `git diff` (unstaged)
   - For many changes: `git diff --stat`

2. **Decide commit boundaries** (split if needed)
   - Split by: feature vs refactor, backend vs frontend, formatting vs logic, tests vs prod code, dependency bumps vs behavior changes.

3. **Stage only what belongs in the next commit**
   - Prefer `git add -p` for mixed changes in one file.
   - Unstage mistakes: `git restore --staged -p` or `git restore --staged <path>`

4. **Review what will be committed**
   - `git diff --cached`
   - Check for: secrets/tokens, debug logging, unrelated formatting churn.

5. **Describe the staged change in 1-2 sentences**
   - "What changed?" + "Why?"
   - If you cannot describe it cleanly, the commit is too big or mixed -- go back to step 2.

6. **Write the commit message** (Conventional Commits required)
   ```
   type(scope): short summary

   Body: what changed and why (not implementation diary).
   Footer: BREAKING CHANGE if needed.
   ```
   Use `git commit -v` for multi-line messages.

7. **Run the smallest relevant verification**
   - Unit tests, lint, or build before moving on.

8. **Repeat** until the working tree is clean.

---

## GitHub Workflows

### New Repository
```bash
gh repo create my-project --public --add-readme
# Or from existing local folder
cd my-project && git init
gh repo create --source=. --public --push
```

### Feature PR
```bash
git checkout -b feature/my-feature
# commit using workflow above
git push -u origin feature/my-feature
gh pr create --title "feat: add feature" --body "Description"
```

### Releases
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --generate-notes
```

### Issue Management
```bash
gh issue create --title "Bug: description" --label "bug" --body "Details..."
gh issue edit 123 --add-assignee @me
gh issue close 123
```

### GitHub Actions
```bash
gh workflow list
gh run list
gh workflow run deploy.yml
gh run view [run-id]
gh run watch [run-id]
```

---

## Deliverable

After committing, provide:
- The final commit message(s)
- A short summary per commit (what/why)
- Commands used to stage/review

## When to Use

- Committing work with clean, logical commits
- Creating PRs for code review
- Starting a new project / creating a GitHub repo
- Releasing a new version with tags
- Managing issues and project tracking
- Checking CI/CD status
