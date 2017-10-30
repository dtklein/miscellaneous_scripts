#!/usr/bin/env bash

echo -e "digraph entrust_trust_web {\n\tlayout=\"dot\"\n\trankdir=\"BT\"">./graph ;
export i=0 ;
for FILE in $(ls ../certs/*.{cer,crt}) ; do 
  SUBJ=$(openssl x509 -in $FILE -noout -subject \
  |awk '
    BEGIN {
      RS="/" ; 
      FS="=" ;
      CN="" ;
      O="" ;
      OUTPUT="" ;
    } ; 
    $1 == "CN" {
      CN=$2 ;
    }
    $1 == "O" {
      O=$2 ;  
    }
    END {
      printf CN "," O ;
    }' |tr -d "\n") ;
  ISS=$(openssl x509 -in $FILE -noout -issuer \
  |awk '
    BEGIN {
      RS="/" ; 
      FS="=" ;
      CN="" ;
      O="" ;
      OUTPUT="" ;
    } ; 
    $1 == "CN" {
      CN=$2 ;
    }
    $1 == "O" {
      O=$2 ;  
    }
    END {
      printf CN "," O ;
    }' |tr -d "\n") ;
  echo -e "\t\"${SUBJ}\" -> \"${ISS}\"" >>./graph ;
done
echo -e "}" >>./graph