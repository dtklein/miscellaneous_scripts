#!/usr/bin/env bash

echo -e "Id,Label">./nodes ; 
export i=0 ; 
for FILE in *.cer ; do 
  SUBJ=$(openssl x509 -in $FILE -noout -subject) ; 
  echo -e "$SUBJ" ; 
  ISS=$(openssl x509 -in $FILE -noout -issuer) ; 
  echo -e "$ISS" ; 
done \
|sort -n \
|uniq \
|while read DN ; do 
  echo ${DN} \
  |awk '
    BEGIN {
      RS="/" ; 
      FS="="
    } ; 
    $1 == "CN" {
      print $2
    }' ; 
done \
|sort \
|uniq \
|while read CN ; do 
  [[ $CN != "" ]] \
    && echo -e "$i,$CN" >>./nodes ;
  export i=$(($i + 1)) ; 
done 