#!/bin/bash --
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# Info: This script safely removes files

# Check if there are arguments
if [ "$#" -eq "0" ]
then
	echo "Expected at least one argument!"
	exit 1
fi

# Check if the directory ~/.trash exists and if not make it
if [ ! -d "$HOME/.trash" ]
then
	mkdir $HOME/.trash
	echo "Created $HOME/.trash"
fi

# Check if in the directory ~/.trash if there are files older then 2 weeks
if find "$HOME/.trash" -type f -mtime +14 -print -quit 2>/dev/null
then
	echo "Cleaning up old files"
	find "$HOME/.trash" -type f -mtime +14 -exec rm -v {} \;
fi

# loop die over de opgegeven bestandsnamen loopt
# Loop over the files that need to be removed compress them with gzip and move them to the directory .trash
while (( $# ))
do
	if [ ! -f "${1}" ]
	then
		echo "${1} is not a file! Skipping..."
		shift
	else
		gzip "${1}"
		mv -v "${1}.gz" "$HOME/.trash"
		shift	
	fi
done
