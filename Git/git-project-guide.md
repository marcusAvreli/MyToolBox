# Git Project Guide

```text
+-------------------------------------------------------+
|                                      ======1_OF_6===  |
|  BACK UP ANGULAR PROJECT ON GIT                       |
|                                                       |
+-------------------------------------------------------+
```

Initialize Git, configure the remote repository, ignore generated folders, and push the first commit.

```bat
git init
git remote add origin <repo_address>

echo node_modules/>> .gitignore
echo dist/>> .gitignore
echo .vscode/>> .gitignore
echo .angular/>> .gitignore

git add -- .
git status
git commit -m "chore: initial commit"
git push -u origin master
```

> Run the following only when these folders were already committed before being added to `.gitignore`.

```bat
git rm -r --cached node_modules
git rm -r --cached dist
git rm -r --cached .vscode
git rm -r --cached .angular

git add -- .
git commit -m "chore: remove ignored files"
git push
```

---

```text
+-------------------------------------------------------+
|                                      ======2_OF_6===  |
|  SUBSEQUENT COMMITS                                   |
|                                                       |
+-------------------------------------------------------+
```

Review changes, stage the required files, commit them, and push.

### One File

```bat
git status
git add tomcat.txt
git diff --cached
git commit -m "feat: add new regex"
git push
```

### All Changes

```bat
git status
git add -- .
git diff --cached
git commit -m "feat: add new regex"
git push
```

### Exclude Folders Temporarily

Use this when a folder is not in `.gitignore` but should not be staged.

```bat
git add . -- ":!somefolder/**" ":!**/some_deep_nested_folder/**"
```

Reference: <https://stackoverflow.com/questions/50316434/add-all-files-using-git-add-except-one-directory>

---

```text
+-------------------------------------------------------+
|                                      ======3_OF_6===  |
|  IDM PLUGIN — GRADLE PROJECT                          |
|                                                       |
+-------------------------------------------------------+
```

Initialize the repository while excluding Angular build files inside `ng2page`.

```bat
git init
git remote add origin https://github.com/marcusAvreli/idmPlugin

echo ng2page/node_modules/>> .gitignore
echo ng2page/dist/>> .gitignore

git add -- .
git status
git commit -m "chore: initial commit"
git push -u origin master
```

> Run these commands only if the folders were already tracked.

```bat
git rm -r --cached ng2page/node_modules
git rm -r --cached ng2page/dist

git add -- .
git commit -m "chore: remove ignored Angular files"
git push
```

Delete the remote `main` branch only when `master` is already the correct default branch.

```bat
git push origin --delete main
```

---

```text
+-------------------------------------------------------+
|                                      ======4_OF_6===  |
|  BRANCHING                                            |
|                                                       |
+-------------------------------------------------------+
```

Create a branch when a complete development chapter is ready to preserve, such as the lazy organization tree core and state-management integration.

### Standard Flow

```bat
git status
git switch -c feat/lazy-org-tree-core
git add -- .
git status
git diff --cached
git commit -m "feat: implement lazy organization tree core"
git push -u origin feat/lazy-org-tree-core
```

### Fast Review

```bat
git status
git diff
git diff --cached
```

- `git diff` shows unstaged changes.
- `git diff --cached` shows staged changes.
- Clean unnecessary files before creating the commit.
