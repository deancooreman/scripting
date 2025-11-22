#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

# This script reads the user input of 2 numbers and calculates the sum and product.
# At the end it checks if sum and product are equal

#function to check if a number is between 1 and 100
check_number(){
if [ $1 -lt 1 -o $1 -gt 100 ];then
	echo "The number has to be between 1 and 100"
	exit 1
fi
}

echo -n "Enter a number: "
read n1
check_number $n1

echo -n "Enter another number: "
read n2
check_number $n2

let sum="$n1+$n2"
let product="$n1+$n2"

echo -e "Sum\t: $n1 + $n2 = $sum"
echo -e "Product\t: $n1 * $n2 = $product"

if [ $sum -eq $product ]; then
	echo "Congratulations sum and product are equal!"
fi
