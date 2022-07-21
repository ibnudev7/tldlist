#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <domain-name> [DNS server]" >&2
  exit 1
fi

dns="$2"
if [ -n "$dns" ]; then
  echo "# Using DNS server '$dns'" >&2
  dns="@$dns"
fi

function check_tld {
  # $dns is not quoted so it's ignored if empty
  if [ -z "$(dig +short SOA "$1" $dns)" ]; then
    echo "$(tput setaf 2)${1}$(tput sgr0) 1337 Domain Tidak Terdaftar"
  else
    echo "$(tput setaf 1)${1}$(tput sgr0) 200 Domain Terdaftar" >&2
  fi
}

tld_url="https://raw.githubusercontent.com/ibnudev7/tldlist/main/cgt.txt"
echo "+ Downloading TLD list ..." >&2
tlds="$(curl --progress-bar "$tld_url" | grep -v "_")" || (echo "Error while downloading TLDs." && exit 1)
count="$(echo "$tlds" | wc -l)"

echo "+ Getting available '$1' domains for $count TLDs ..." >&2

workers=32
for ((i=$((workers-1)); i > 0; i--)); do
  for tld in $(echo "$tlds" | awk "(NR+$i) % $workers == 0"); do
    check_tld "${1}.${tld}"
  done &
done

# Wait for everything to be done
wait
echo "Done!" >&2
echo "$(tput setaf 1)${1}$(tput sgr0) 200 Domain Terdaftar" > mantap.txt
echo "$(tput setaf 2)${1}$(tput sgr0) 1337 Domain Tidak Terdaftar" > hadeh.txt
