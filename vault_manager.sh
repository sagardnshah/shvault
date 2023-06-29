#!/bin/bash

# argument count check
if [[ $# -ne 1 ]]; then
    echo "Error: File not Found"
    echo "Usage: $0 encrypted_file"
    exit 1
fi

# accept password
read -s -p "Enter vault password: " password
echo

# Test input file for openssl encryption to prevent accidentally opening something else
openssl enc -aes-256-cbc -d -iter 100000 -in "$1" -out /dev/null -pass "pass:$password" 2>/dev/null
ret=$?
if [[ $ret -ne 0 ]]; then
    echo "Pass in a valid file encrypted with openssl"
    exit 1
fi

# open decrypted contents in vim, and save on exit
temp_file=$(mktemp)
chmod 600 $temp_file
decrypted_plaintext="$(openssl enc -aes-256-cbc -d -iter 100000 -in $1 -pass "pass:$password")"
echo "$decrypted_plaintext" > "$temp_file"
vi "$temp_file"
edited=$(cat "$temp_file")
rm "$temp_file"

# Dump edited content back into encrypted file
echo "$edited" | openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter 100000 -pass "pass:$password" -out "$1"

echo "Success"

####################################
# scraps
####################################

function create_vault {
    # # using source file
    # unencrypted_src_file=blank_file
    # touch $unencrypted_src_file
    # openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter 100000 -pass pass:$password -in $unencrypted_src_file -out $encrypted_dst_file

    #setup blank file
    openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter 100000 -pass pass:password -out vault <<< ""
}

# #encrypt
# openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -iter 100000 -pass pass:$password -out vault <<< ""

# #decrypt
# openssl enc -aes-256-cbc -d -iter 100000 -in vault -out out -pass pass:password

# temp file
# decrypted_file=$(openssl enc -aes-256-cbc -d -iter 100000 -in vault -pass "pass:password")
