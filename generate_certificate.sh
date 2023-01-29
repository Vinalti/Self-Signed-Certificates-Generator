#!/bin/bash
# Author :   https://github.com/Vinalti
# Project :  https://github.com/Vinalti/Home-Certificate-Generator
# Created :  2023-01-29
# Last Edit: 2023-01-29
#

# GLOBAL VARIABLES
CA_dir="$(pwd)/CA"
private_key="${CA_dir}/ca-key.pem"
CA="${CA_dir}/CA.pem"
default_duration=0
force=false

# Display Short usage help
function short_usage(){
    echo "> USAGE: $(basename $0) [-h] [-C <cert>] [-K <key>]"
    echo ""
    echo "> OPTS:"
    echo "    -h          Display this help message"
    echo "    -f          Overwrite certificate if it exists"
    echo "    -K <key>    Use <key> as CA private key "
    echo "    -C <cert>   Use <cert> as CA public certificate"
    echo "    -d <days>   Set new certificate duration to <days>"
}

# display long help
function help(){
    short_usage
    echo "          - - -"
    echo ""
    echo " > HowTo import Root CA:"
    echo "- Debian based (as root / with sudo): "
    echo " \$ cp CA.pem /usr/local/share/ca-certificates/custom-ca.crt"
    echo " \$ update-ca-certificates"
    echo ""
    echo "- Fedora (as root / with sudo): "
    echo " \$ cp CA.pem /usr/share/pki/ca-trust-source/anchors/ca.pem"
    echo " \$ update-ca-trust"
    echo ""
    echo "- Windows (as Admin):"
    echo " \$ Import-Certificate -FilePath \"C:\\CA.pem\" -CertStoreLocation Cert:\\LocalMachine\\Root"
    echo ""
    echo "- Windows (as User):"
    echo " \$ Import-Certificate -FilePath \"C:\\CA.pem\" -CertStoreLocation Cert:\\CurrentUser\\Root"
    exit 0
}

# Prompt user to press ENTER to continue
function enter_to_continue(){
    read -p "  [Press ENTER to Continue or CTRL+C to Cancel]"
}


# START OF SCRIPT
# - Parse options
while getopts 'hfK:C:d:' opt; do
  case "$opt" in

    C)
      CA="$OPTARG"
      echo "[info] -${opt}: Root CA set to '$CA'"
      ;;

    K)
      private_key="$OPTARG"
      echo "[info] -${opt}: Root CA Private Key set to '$OPTARG'"
      ;;
   
    d)
      default_duration="$OPTARG"
      echo "[info] -${opt}: Certificate duration set to '$OPTARG' days"
      ;;

    f)
      force=true
      echo "[info] -${opt}: Certificate will be overwritten if it already exist"
      ;;

    ?|h)
      help
      ;;
  esac
done

# - Generate CA Private Key if it doesn't exists
if [ ! -f "$private_key" ]; then
    mkdir -p $(dirname "${private_key}")
    echo ">> Private key '$private_key' not found : creating new private key..." 
    echo " > For security purpose insert secure password when requested." 
    openssl genrsa -aes256 -out "$private_key" 4096
    if [[ $? -ne 0 ]]; then
        echo "[E101] An error occured while generating private key."
        exit 101
    fi
    echo " > Private key '$private_key' created." 
    # Check if CA already exists. If so, new CA will be named `-new.pem`
    if [ -f "$CA" ]; then
        echo "${CA} exists but is no more valid. It will be moved to ${CA}.bak"
        mv "${CA}" "${CA}.bak"
    fi
fi
# - Generate CA public certificate if it doesn't exists
if [ ! -f "$CA" ]; then
    echo ">> Creating CA $CA..." 
    openssl req -new -x509 -sha256 -days 5475 -key "$private_key" -out "$CA"
    if [[ $? -ne 0 ]]; then
        echo "[E102] An error occured while generating CA '$CA'."
        exit 102
    fi
    echo " > CA '$CA' created." 
fi

# - Allow user to create several certificate at once (loop)
while [[ 1 -eq 1 ]]; do
    echo ""
    echo ">> Starting process to issue new certificate..."
    sleep 1
    read -p " > Enter certificate ID (e.g domain name): " id
    duration=$default_duration
    if [[ default_duration -eq 0 ]]; then
        read -p " > Enter certificate DURATION in days (e.g '365'): " duration
    fi

    # - Check directory (cert_id) doesn't already exists
    dir=$id
    if [ -d "$dir" ]; then
        if [[ "$force" == true ]]; then
            echo " > WARNING: directory '$dir' already exists and will be overwritten. Are you sure?"
            enter_to_continue
            rm -f ${dir}/*
        else
            echo " > ERROR: directory '$dir' already exists. Please choose another certificate id."
            continue
        fi
    fi

    # - Create directory, initialize filenames
    mkdir -p $dir
    key="${dir}/${id}.priv.key"
    csr="${dir}/.${id}_request.csr"
    pem="${dir}/${id}.pub.pem"
    chain="${dir}/${id}.chain.pem"
    cnf="${dir}/.config.txt"

    # - Generate Private Key
    openssl genrsa -out $key 4096
    if [[ $? -ne 0 ]]; then  echo "[E201] An error occured while generating certificate $id."; continue; fi
    # - Generate Certificate Request
    openssl req -new -sha256 -subj "/CN=$id" -key $key -out $csr
    if [[ $? -ne 0 ]]; then  echo "[E202] An error occured while generating certificate $id."; continue; fi
    # - Prompting for Certificate Alternative Name
    default_alt="DNS:${id}"
    echo " > Enter SubjectAltNames (type ENTER when done)"
    echo "   Default: DNS:${id} "
    echo "   Example: "
    echo "   - 'DNS:your.domain.local'"
    echo "   - 'IP:192.168.1.1'"
    alt_names="subjectAltName="
    while true; do 
        read -p " $>" altname
        if [ ${#altname} -eq 0 ]; then
            break
        fi
        if [ ${#alt_names} -gt 16 ]; then
            alt_names="${alt_names},${altname}"
        else
            alt_names="${alt_names}${altname}"
        fi
    done
    if [ ${#alt_names} -lt 18 ]; then
        alt_names="subjectAltName=${default_alt}"        
    fi

    echo "$alt_names" >> $cnf
    echo " > The following alt names has been saved:"
    echo "  -> " $(cat $cnf)
    echo "  If you made an error, edit file '$cnf' before to continue"

    enter_to_continue

    # - Generating Public Certificate
    openssl x509 -req -sha256 -days "$duration" -in "$csr" -CA "$CA" -CAkey "$private_key" -out "$pem" -extfile "$cnf" -CAcreateserial
    if [[ $? -ne 0 ]]; then  echo "[E203] An error occured while generating certificate $id."; continue; fi
    # - Generating Certificate Chain (incl. root CA public key)
    cat $pem > $chain
    cat $CA >> $chain
    if [[ $? -ne 0 ]]; then  echo "[E204] An error occured while generating certificate $id."; continue; fi
    # - Inform user of success
    echo "Certificate $id has been issued."
    echo " - private key: '$key'"
    echo " - public certificate: '$chain'"
    sleep 1
    echo ""
    read -p "Press ENTER to create another certificate, or CTRL+C to stop here"
done
echo "Done"0
echo "See `$0 -h` for importation instructions "

