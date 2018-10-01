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


#$mycleos push action registrynft addconfig '["bcdutoken", "BCDU", 8, 8500]' -p registrynft



#$mycleos push action registrynft create '{"issuer":"registrynft", "symb":"BCDU", "payment_token":"bcdu","symbol":"bcdu","precision":"6","price_per_centicaratx100":"500"}' -p bitcarbon

#$mycleos push action registrynft issue '{"issuer":"bitcarbon","registrant":"gia","report_num":"505211","name":"diamonds","lab":"gia","shape_and_cutting_style":"triangle","heightx100":"300","widthx100":"100", "lengthx100":"500","centicarat":"5", "color_grade":"g", "clarity_grade":"s11", "cut_grade":"excellent", "polish":"excellent", "symmetry":"excellent", "flourescence":"white", "qty":"5 BCDU", "urs":"testing1" }' -p bitcarbon

#$mycleos push action registrynft addclaritych '[505211, "Feather"]' -p registrynft
#$mycleos push action registrynft addclaritych '[505211, "Feather"]' -p registrynft
#$mycleos push action registrynft addclaritych '[505211, "Crystal"]' -p registrynft

#$mycleos push action registrynft addinscript '[505211, "GIA 2437894"]' -p registrynft
#$mycleos push action registrynft addinscript '[505211, "For my lovely wife"]' -p registrynft
#$mycleos push action registrynft addinscript '[505211, "GIA 2437894"]' -p registrynft

#$mycleos push action registrynft transfer '{"from":"registrynft", "to":"bitcarbon", "report_num":"505211", "memo":"transfer1"}' -p bitcarbon
#$mycleos push action registrynft transfer '{"from":"registrynft", "to":"bitcarbon", "report_num":"505211", "memo":"transfer2"}' -p bitcarbon
#$mycleos push action registrynft transfer '{"from":"registrynft", "to":"bitcarbon", "report_num":"505211", "memo":"transfer3"}' -p bitcarbon




