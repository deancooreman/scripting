#! /bin/bash
#
## Usage: ./backup.sh [OPTIONS] [DIR]
##
## DIR
##              The directory to back up
##              Default: the current user's home directory
##
## OPTIONS
##
##  -h, -?, --help
##              Print this help message and exit
##
##  -d, --destination DIR
##              Set the target directory to store the backup file
##              Default:  /tmp

#---------- Shell options ------------------------------------------------------
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#---------- Variables ----------------------------------------------------------

# Time stamp for the backup file
timestamp="$(date +'%Y%m%d%H%M')"

# Path of the directory to back up
source=$HOME

# Directory where to store the backup file
destination="/tmp"

#---------- Main function ------------------------------------------------------
main() {
  process_cli_args "${@}"
  
  echo "Backup from ${source} to ${destination}"

  check_source_dir
  check_destination_dir

  do_backup
}

#---------- Helper functions ---------------------------------------------------

# Usage: process_cli_args "${@}"
process_cli_args() {
  # Use a while loop to process all positional parameters
  while (( $# ))
  do
    # Put the first parameter in a variable with a more descriptive name
    option="${1}"

    # Use case statement to determine what to do with the currently first
    # positional parameter
    case $option in
      # If -h, -? or --help was given, call the usage function and exit
      "-h" | "-?" | "--help")
      		usage
		exit 0
      ;;    
      
      # If -d or --destination was given, set the variable destination to
      # the next positional parameter.
      "-d" | "--destination")
      		shift
		destination="${1}"
      ;;    
      
      # If any other option (starting with -) was given, print an error message
      # and exit with an error status
      -*)
      		echo "Option not available!" >&2 1>/dev/null
		exit 1
      ;;
      
      # In all other cases, we assume the directory to back up was given.
      *)
      source="${1}"
      ;;
    esac 
    shift 
  done    
}

# Usage: do_backup
#  Perform the actual backup
do_backup() {
  local source_dirname backup_file
  # Get the directory name from the source directory path name
  # e.g. /home/osboxes -> osboxes, /home/osboxes/Downloads/ -> Downloads
  # Remark that this should work whether there is a trailing `/` or not!
  source_dirname="$(basename "${source%/}")"
  
  # Name of the backup file
  backup_file="${source_dirname}-${timestamp}.tar.bz2"

  # logfile next to the archive
  logfile="${destination}/backup-${timestamp}.log"

  # Create the bzipped tar-archive on the specified destination
  fullpath_parent="$(dirname "${source}")"

  # Run tar and redirect both stdout and stderr to the logfile
  tar -cjf "${destination}/${backup_file}" -C "${fullpath_parent}" "${source_dirname}" > "${logfile}" 2>&1

  # Report exit status
  if [ $? -eq 0 ]; then
    echo "Backup created: ${destination}/${backup_file}"
    echo "Tar output (stdout+stderr) written to: ${logfile}"
  else
    echo "Backup failed. See ${logfile} for details." >&2
    exit 1
  fi
}

# Usage: check_source_dir
#   Check if the source directory exists (and is a directory). Exit with error
#   status if not.
check_source_dir() {
  if [ ! -d "${source}" ]; then
	echo "Source is not a directory or does not exist!" >&2
	exit 1
  fi
}

# Usage: check_destination_dir
#   Dito for the destination directory
check_destination_dir() {
  if [ ! -d "${destination}" ]; then
	echo "Destination is not a directory or does not exist!" >&2
	exit 1
  fi
}

# Print usage message on stdout by parsing start of script comments.
# - Search the current script for lines starting with `##`
# - Remove the comment symbols (`##` or `## `)
usage() {
    grep "^##" "$0" | sed 's/^##\([ ]\)\?//'
}

main "${@}"
