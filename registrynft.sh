#!/bin/bash

if [[ $# -lt 2 ]]; then
   echo "usage: registrynft.sh <ACCOUNT_NAME> <CONTRACT_NAME> <CLEAN>"
   exit 1
elif [[ $# -eq 3 ]]; then
   if [[ $3 -eq 'CLEAN' ]]; then
      echo "Clean option supplied..."
      echo "*** abi, wast, wasm files purged...."
      rm *.abi *.wa??
      exit 1
   fi
fi



ACCOUNT=$1
CONTRACT=$2
CLEAN=$3

eoscppx=~/eos/build/tools/eosiocpp
mycleos=~/eos/build/programs/cleos/cleos

$eoscppx -g ${CONTRACT}.abi ${CONTRACT}.cpp &&
$eoscppx -o ${CONTRACT}.wast ${CONTRACT}.cpp &&
$mycleos set contract ${ACCOUNT} ../${CONTRACT}
