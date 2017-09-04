#!/usr/bin/env bash

for ip in 192.168.2.{1..20};
do
   printf "%s:\t%s\n" \
     "${ip}" \
     "$(printf 'Q' \
       | openssl s_client -showcerts -connect ${ip}:443 2> /dev/null \
       | openssl x509 -noout -issuer 2> /dev/null)" ;
done;
