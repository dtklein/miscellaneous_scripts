#!/usr/bin/env bash

echo -e "Source,Target">./edges ;
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
  SUBJ_Num=$(awk 'BEGIN {FS=","} ; $2 == "'"${SUBJ_CN}"'" {print $1}' ./nodes) ;
  ISS_Num=$(awk 'BEGIN {FS=","} ; $2 == "'"${ISS_CN}"'" {print $1}' ./nodes) ;
  [[ $SUBJ_Num == "" ]] && echo -e "Could not find Subject ${SUBJ_CN} in nodes table" >&2 ;
  [[ $ISS_Num == "" ]] && echo -e "Could not find Issuer ${ISS_CN} in nodes table" >&2 ;
  echo -e "${SUBJ_Num},${ISS_Num}" >>./edges ;
done