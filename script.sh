#!/bin/bash

# Function to show the diff and perform actions after choosing to commit
function showDiffAndCommit() {
  local folder=$1

  # Change to the repository folder
  cd "$folder" || return

  # Show the diff of changes
  git diff

  # Prompt for action
  read -rp "Do you want to (C)ommit, (A)dd to .gitignore, (L)ist contents, or (D)elete the folder? (C/c for commit, A/a for add to .gitignore, L/l for list contents, D/d for delete): " answer

  if [[ $answer == [Cc] ]]; then
    # Show the diff again
    git diff

    # Prompt for file(s) to add to .gitignore
    read -rp "Enter the file(s) to add to .gitignore (space-separated): " files

    # Add file(s) to .gitignore
    gitignorePath="$folder/.gitignore"
    echo -e "\n$files\n" >> "$gitignorePath"
    echo "Added '$files' to .gitignore successfully."

    # Show the diff again
    git diff

    # Prompt for commit message
    read -rp "Enter the commit message: " commitMessage

    # Commit the changes
    git commit -am "$commitMessage"

# Check if 'origin' remote exists
if ! git remote | grep -q "origin"; then
  # Prompt for GitHub repository name
  read -rp "Enter the name for your GitHub repository: " repoName

      # Create a new repository on GitHub
      gh repo create "$repoName" --confirm --public
fi

    # Push the changes to the remote repository
    git push origin master
  elif [[ $answer == [Aa] ]]; then
    # Prompt for file(s) to add to .gitignore
    read -rp "Enter the file(s) to add to .gitignore (space-separated): " files

    # Add file(s) to .gitignore
    gitignorePath="$folder/.gitignore"
    echo -e "\n$files\n" >> "$gitignorePath"
    echo "Added '$files' to .gitignore successfully."

    # Call showDiffAndCommit again to show the diff and provide the option to commit
    showDiffAndCommit "$folder"
  elif [[ $answer == [Ll] ]]; then
    # List the contents of the folder
    ls -l

    # Call showDiffAndCommit again to prompt for action
    showDiffAndCommit "$folder"
  elif [[ $answer == [Dd] ]]; then
    # Confirm the deletion
    read -rp "Are you sure you want to delete the folder '$folder'? This action cannot be undone. (Y/y for yes, any other key to cancel): " confirmDelete

    if [[ $confirmDelete == [Yy] ]]; then
      # Delete the folder
      echo "Deleting '$folder'..."
      rm -rf "$folder"
      echo "Deleted '$folder' successfully."
    else
      echo "Deletion canceled."
    fi
  fi
}

# Function to check Git status and perform actions
function checkGitStatus() {
  local folder=$1

  # Change to the repository folder
  cd "$folder" || return

  # Check if the folder is a Git repository
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Check if there are uncommitted changes
    if [[ -n "$(git status --porcelain)" ]]; then
      echo "Uncommitted changes found in '$folder'"

      # Call showDiffAndCommit to show the diff and provide the option to commit
      showDiffAndCommit "$folder"
    else
      echo "No uncommitted changes found in '$folder'"
    fi
  else
    echo "'$folder' is not a Git repository"

    # Get the date modified of the folder
    dateModified=$(date -r "$folder" +"%Y-%m-%d %H:%M:%S")

    # Prompt for action
    read -rp "Do you want to initialize it as a new Git repository and push to GitHub (I/i), or delete the folder (D/d)? (I/i for initialize, D/d for delete): " initAnswer

    if [[ $initAnswer == [Ii] ]]; then
      # Initialize a new Git repository
      git init

      showDiffAndCommit "$folder"

    elif [[ $initAnswer == [Dd] ]]; then
      # Confirm the deletion
      read -rp "Are you sure you want to delete the folder '$folder'? This action cannot be undone. (Y/y for yes, any other key to cancel): " confirmDelete

      if [[ $confirmDelete == [Yy] ]]; then
        # Delete the folder
        echo "Deleting '$folder'..."
        rm -rf "$folder"
        echo "Deleted '$folder' successfully."
      else
        echo "Deletion canceled."
      fi
    fi
  fi
}

# Specify the folder containing your Git repositories
gitFolder="/Users/larryhudson/github.com/larryhudson"

# Read the directory to get a list of repositories
files=("$gitFolder"/*)

# Check Git status for each repository
for repoFolder in "${files[@]}"; do
  if [[ -d "$repoFolder" ]]; then
    folderName=$(basename "$repoFolder")
    dateModified=$(date -r "$repoFolder" +"%Y-%m-%d %H:%M:%S")
    echo -e "Folder: $folderName\nDate Modified: $dateModified"

    checkGitStatus "$repoFolder"
  else
    echo "'$repoFolder' is not a directory"
  fi
done

