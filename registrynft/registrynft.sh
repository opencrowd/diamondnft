#!/bin/bash

eoscppx=~/eos/build/tools/eosiocpp
mycleos=~/eos/build/programs/cleos/cleos


if [[ $# -lt 2 ]]; then
   echo "usage: registrynft.sh <ACCOUNT_NAME> <CONTRACT_NAME> <CLEAN>"
   exit 1
elif [[ $# -eq 3 ]]; then
   if [[ $3 -eq "CLEAN" ]]; then
      echo "Clean option supplied..."
      echo "*** abi, wast, wasm files purged...."
      rm *.abi *.wa??
      exit 1
   fi
fi

ACCOUNT=$1
CONTRACT=$2
CLEAN=$3

$mycleos set contract --clear ${ACCOUNT} ../${CONTRACT}
$eoscppx -g ${CONTRACT}.abi ${CONTRACT}.cpp &&
$eoscppx -o ${CONTRACT}.wast ${CONTRACT}.cpp &&
$mycleos set contract ${ACCOUNT} ../${CONTRACT}


# ---uncomment when project is built
#cleos push action registrynft create '{"issuer":"registrynft", "symb":"BCDU", "price_per_centicarat":"135"}' -p registrynft@active
#cleos push action registrynft issue '{"registrant":"nft", "report_num":"2174341", "name":"GIA Diamonds", "lab":"GIA Laboratories, Miami", "shape_and_cutting_style":"Triangular", "heightx100":"100", "widthx100":"100", "lengthx100":"1299", "centicarat":"299", "color_grade":"blue", "clarity_grade":"Excellent", "cut_grade":"Excellent", "polish":"Excellent", "symmetry":"Excellent", "flourescence":"crystal", "qty":"1755 BCDU", "urs":"First Diamond Registrtation"}' -p registrynft@active
#cleos push action registrynft transfer '{"from":"registrynft", "to":"bcdutoken", "report_num":"2174341","quantity":"355 BCDU", "memo":"transfer3"}' -p registrynft
#$mycleos push action registrynft addclaritych '[505211, "Feather"]' -p registrynft
#$mycleos push action registrynft addclaritych '[505211, "Feather"]' -p registrynft
#$mycleos push action registrynft addclaritych '[505211, "Crystal"]' -p registrynft

#$mycleos push action registrynft addinscript '[505211, "GIA 2437894"]' -p registrynft
#$mycleos push action registrynft addinscript '[505211, "For my lovely wife"]' -p registrynft
#$mycleos push action registrynft addinscript '[505211, "GIA 2437894"]' -p registrynft


# ----- Unused
#cleos push action registrynft create '{"issuer":"registrynft", "symb":"AFT", "payment_token":"afttoken", "price_per_centicaratx100":"55"}' -p registrynft
#cleos push action registrynft issue '{"registrant":"registrynft","report_num":"975305","name":"diamonds","lab":"gia","shape_and_cutting_style":"triangle","heightx100":"300","widthx100":"100", "lengthx100":"500","centicarat":"5", "color_grade":"g", "clarity_grade":"s11", "cut_grade":"excellent", "polish":"excellent", "symmetry":"excellent", "flourescence":"white", "qty":"1000000 BCDU", "urs":"testing1" }' -p registrynft
#cleos push action registrynft transfer '{"from":"registrynft", "to":"registry", "report_num":"975405", "quantity":"505 AFT", "memo":"transfer1"}' -p registrynft
#cleos push action registrynft transfer '{"from":"registrynft", "to":"bcdutoken", "report_num":"975205", "quantity":"505 BCDE", "memo":"transfer1"}' -p registrynft

#-----------unit test cases
#cd $EOS/build/unittests
#./unit_test --show-progress=yes --run_test=registrynft_tests

