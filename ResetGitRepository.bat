@echo off
REM ------------------------------
REM Reset Git repository history
REM Repo: https://github.com/mehrdadhamidi2002/TssUpdate.git
REM Local path: C:\Users\mehrdad\TssUpdate
REM ------------------------------

cd /d C:\Users\mehrdad\TssUpdate

echo [1] Removing old .git folder...
rmdir .git /s /q

echo [2] Initializing new git repo...
git init

echo [3] Adding all files...
git add .

echo [4] Creating new commit...
git commit -m "Reset clean repo with latest files"

echo [5] Setting branch to main...
git branch -M main

echo [6] Setting remote URL...
git remote remove origin 2>nul
git remote add origin https://github.com/mehrdadhamidi2002/TssUpdate.git

echo [7] Pushing to GitHub (force push)...
git push -f origin main

echo [DONE] Repository reset and pushed successfully!
pause
