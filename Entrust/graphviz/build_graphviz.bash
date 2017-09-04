#!/usr/bin/env bash

echo -e "digraph entrust_trust_web {\n\tlayout=\"dot\"\n\trankdir=\"BT\"">./graph ;
export i=0 ;
for FILE in *.cer ; do 
  SUBJ=$(openssl x509 -in $FILE -noout -subject) ; 
  ISS=$(openssl x509 -in $FILE -noout -issuer) ; 
  SUBJ_CN=$(echo ${SUBJ} \
  |awk '
    BEGIN {
      RS="/" ; 
      FS="="
    } ; 
    $1 == "CN" {
      print $2
    }') ;
  ISS_CN=$(echo ${ISS} \
  |awk '
    BEGIN {
      RS="/" ; 
      FS="="
    } ; 
    $1 == "CN" {
      print $2
    }') ;
  echo -e "\t\"${SUBJ_CN}\" -> \"${ISS_CN}\"" >>./graph ;
done
echo -e "}" >>./graph