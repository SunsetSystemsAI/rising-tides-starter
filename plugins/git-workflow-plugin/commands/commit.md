---
description: Stage, review, and commit changes with conventional commit messages
---

## /git-workflow:commit

### Steps

1. Run `git status` to see all changes
2. Run `git diff` to review unstaged changes
3. Run `git diff --cached` to review staged changes
4. Group related changes into logical commits
5. Stage files for each logical commit: `git add <files>`
6. Write a conventional commit message:
   - `feat:` for new features
   - `fix:` for bug fixes
   - `refactor:` for code restructuring
   - `docs:` for documentation
   - `chore:` for maintenance
7. Include scope if applicable: `feat(auth): add OAuth flow`
8. Add body if the change needs explanation
9. Commit: `git commit -m "message"`
10. Repeat for remaining logical groups

### Rules
- Never combine unrelated changes in one commit
- Never use `git add .` without reviewing what's staged
- Never amend commits that have been pushed
- Always use present tense in commit messages
