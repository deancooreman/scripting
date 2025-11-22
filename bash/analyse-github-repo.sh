#! /bin/bash --
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#Check if the script has exact 1 argument
if [ ! "${#}" -eq 1 ]
then
	echo "Expected exact 1 argument!"
	exit 1
fi

#Check if the argument is a directory
if [ ! -d ${1}  ]
then
	echo "The argument has to be a directory!"
	exit 1
fi

#Check if the directory is a github repo
if [ ! -d "${1}/.git" ]
then
	echo "The directory has to be a github repo!"
	exit 1
fi

#Count the amount of commits and give an encouragement based on the amount
commits=$(git log --pretty=oneline -C "${1}" | wc -l)

if [ "$commits" -eq 0 ]
then
	echo "Come on make your first commit!"
elif [ "$commits" -eq 1 ]
then
	echo "Already 1 commit, good start!"
elif [ "$commits" -ge 2 -a "$commits" -le 10 ]
then
	echo "You already made $commits commits, go on!"
else
	echo "Fantastic work, already $commits commits!"
fi

#Check local changes
changes=$(git status -s)

if [ -z "$changes" ]
then
	echo "No local changes, you are doing great!"
else
	echo "You still have local changes commit them ASAP!"
fi

#Check if README file is made
if [ -f "${1}/README.md" ]
then
	echo "README.md exists, good job!"
else
	echo "README.md doesn't exist, create one with some info about the project"
fi

#Check if LICENSE file is made
if [ -f "${1}/LICENSE.md" ]
then
	echo "LICENSE.md exists, good job!"
else
	echo "LICENSE.md doesn't exist, create one with some info about the license"
fi

#Check if .gitignore file is made
if [ -f "${1}/.gitignore"  ]
then
	echo "gitignore exists, good job!"
else
	echo "gitignore doesn't exist, create one with some info about the project"
fi

# Loop over all files in the directory
# Checks if the file is a directory
# Checks if the file is a special charachter file
# Checks if the file is ASCII text, with CRLF line terminators
# Checks if filetype starts with ELF
# Checks for .sh scripts and control if they are executable
for file in "${1}"/*
do
	if [ -d "$file" ]
	then
		echo "Directory skipping..."
	elif [ -b "$file" -o -c "$file" ]
	then
		echo "$file is a special file. Does this belongs in the repo?"
	else
		type=$(file "$file")

		case "$type" in
			*"ASCII text, with CRLF line terminators"*)
				echo "$file has DOS line endings, convert with dos2unix"
			;;
			*ELF*)
				echo "$file is a binary executable, does this belong in this repo?"
			;;
			*"Bourne-Again shell script, ASCII text executable"*)
				if [ ! -x "$file"  ]
				then
					echo "Script is not executable, use: chmod +x \"$file\""
				else
					echo "Script is executable: $file"
				fi
			;;
		esac
	fi
done
