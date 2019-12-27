## Using Git

- [DataCamp Course](https://campus.datacamp.com/courses/introduction-to-git-for-data-science/basic-workflow?ex=1)
- [Github for Course](https://github.com/datacamp/courses-introduction-to-git-for-data-science)



#### Part 1 - Basic Workflow

##### Quick commands

```
Ctrl K  # delete a line.
Ctrl U  # un-delete a line.
Ctrl O  # save the file ('O' for 'output').
Ctrl X  # exit the editor.

# Where history is located
/home/sam/repo_example/.git
```



##### View what has happened

```
# Which files have been changed? (Don't need to have been added to the repo yet)
git status

# Project history
git log
  # `space` to go to next page
  # `q` to quit and return to normal terminal
  
# File history
git log path/to/my_file
```



##### Adding new stuff

```
# Add file
git add filename

# Difference between curr file and saved file
git diff

# Commit
git commit -m "A message."

# Re-commit, diff message
git commit --amend - m "new message"
```

---



#### Part 2 - Repositories

Commit - each commit has unique hash

- Tree - see all files in repo

- Blob - snapshot of the files

```
# Repo history (the -2 is optional but will only show 2 most recent)
git log -2

# Repo history - specific commit
git show a6r52

# View 2nd to last commit
git show HEAD~1

# View details about file history
git annotate file_name.txt

# Which files have been changed between now and 2 commits ago?
git diff HEAD..HEAD~2

# Remove files that are not being tracked (haven't beed "added")
git clean -f
```

---



#### Part 3 - Undo

```
# These commands are before a file has been added to the repo

# Unstage a file
git reset HEAD

# Get rid of changes - bring to previous version
git checkout -- filename.txt
```

---



#### Part 4 - Branches

```
# View all branches in repo
git branch

# Different files between a branch and the master
git diff master..path/branch_name

# Change to different branch
git checkout branch_name

# Remove file
git rm file.txt

# Create branch and go to it
git checkout -b branch-name

# Merge branch into master
git merge branch-name master -m "A message"
```

---



#### Part 5 - Collab

```
# Create repo
git init repo_name

# Create repo from a folder in computer
cd /path/to/folder
git init

# Clone repo
git clone /path/to/repo new_name

# Add remote
git remote add remote-name /path/to/remote

# Pull
git pull remote-name branch-name

# Push
git push remote-name branch-name
```

