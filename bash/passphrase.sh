#! /bin/bash
#
## Usage: ./passphrase.sh [N] [WORDLIST]
##        ./passphrase.sh -h|--help
##
## Generate a passphrase, as suggested by http://xkcd.com/936/
##
##   N
##            The number of words the passphrase should consist of
##            Default: 4
##   WORDLIST
##            A text file containing words, one on each line
##            Default: /usr/share/dict/words
##
## OPTIONS
##   -h, --help
##              Print this help message
##
## EXAMPLES
##
##   $ ./passphrase.sh -h
##   ...
##   $ ./passphrase.sh
##   unscandalous syagush merest lockout
##   $ ./passphrase.sh /usr/share/hunspell/nl_BE.dic 3
##   tegengif/Ze Boevink/PN smekken 

#---------- Shell options -----------------------------------------
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable

#---------- Variables ---------------------------------------------
word_list=/usr/share/dict/words
num_words=4

#---------- Main function -----------------------------------------
main() {
  process_cli_args "${@}"
  generate_passphrase
}

# Usage: generate_passphrase
# Generates a passphrase with ${num_words} words from ${word_list}
generate_passphrase() {
passphrase=""

i=$num_words
while [ "${i}" -ge '1' ]
do
	word=$(shuf $word_list | head -1)
	passphrase+="$word "
	(( i-- ))
done

echo "$passphrase"
}

# Usage: process_cli_args "${@}"
#
# Iterate over command line arguments and process them
process_cli_args() {
  # If the number of arguments is greater than 2: print the usage
  # message and exit with an error code
if [ "${#}" -gt 2 ]; then
	echo "There are more than 2 arguments given!" >&2 1>/dev/null
	exit 1
fi
  # Loop over all arguments
  while (( $#  ))
  do

    # Use a case statement to determine what to do
    case ${1} in
      # If -h or --help was given, call usage function and exit
      "-h" | "--help")
      		usage
		exit 0
      ;;    

      # If any other option was given, print an error message and exit
      # with status 1
      -*)
     		echo "Option not available!" >&2 1>/dev/null
	        exit 1
      ;;    

      # In all other cases, we assume N or WORD_LIST was given
      *)
        # If the argument is a file, we're setting the word_list variable
        if [ -f "${1}" ]; then
		word_list="${1}"
        # If not, we assume it's a number and we set the num_words variable
	else
		num_words="${1}"
	        echo "num words set"	
	fi
    esac

    shift

  done
        
}

# Print usage message on stdout by parsing start of script comments.
# - Search the current script for lines starting with `##`
# - Remove the comment symbols (`##` or `## `)
usage() {
	grep "^##" "$0" | sed 's/^##\([ ]\)\?//'
}

# Call the main function
main "${@}"
