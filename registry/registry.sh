
# Setup accounts and contracts
cleos create account eosio registry EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn
cleos create account eosio registrant EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn
cleos create account eosio bcdutoken EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn
cleos create account eosio bitcarbon EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn

eosiocpp -g /eosdev/registry/registry.abi /eosdev/registry/registry.hpp && eosiocpp -o /eosdev/registry/registry.wast /eosdev/registry/registry.cpp
eosiocpp -g /eosdev/bcdutoken/bcdutoken.abi /eosdev/bcdutoken/bcdutoken.hpp && eosiocpp -o /eosdev/bcdutoken/bcdutoken.wast /eosdev/bcdutoken/bcdutoken.cpp

cleos set contract registry /eosdev/registry
cleos set contract bcdutoken /eosdev/bcdutoken

cleos push action eosio updateauth '{"account":"registrant","permission":"active","parent":"owner","auth":{"keys":[{"key":"EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn", "weight":1}],"threshold":1,"accounts":[{"permission":{"actor":"registry","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p registrant

# Setup BCDU
cleos push action bcdutoken create '["bitcarbon", "1000000000.0000 BCDU"]' -p bcdutoken
cleos push action bcdutoken issue '["registrant", "100000.0000 BCDU"]' -p bitcarbon

# Configure registry
cleos push action registry addconfig '["bcdutoken", "BCDU", 4, 8500]' -p registry

# Register diamond
cleos push action registry regdiamond '[2141438172, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant"]' -p registrant
cleos push action registry addclaritych '[2141438172, "Crystal"]' -p registry
cleos push action registry addclaritych '[2141438172, "Feather"]' -p registry
cleos push action registry addinscript '[2141438172, "GIA 2141438172"]' -p registry
cleos push action registry addinscript '[2141438172, "For my lovely wife Deborah"]' -p registry
cleos push action registry addcomment '[2141438172, "Survived WW2 Battle of Normandy"]' -p registry


# Try to register without BCDU
cleos create account eosio registrant2 EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn
cleos push action eosio updateauth '{"account":"registrant2","permission":"active","parent":"owner","auth":{"keys":[{"key":"EOS7ckzf4BMgxjgNSYV22rtTXga8R9Z4XWVhYp8TBgnBi2cErJ2hn", "weight":1}],"threshold":1,"accounts":[{"permission":{"actor":"registry","permission":"eosio.code"},"weight":1}],"waits":[]}}' -p registrant2

cleos push action registry regdiamond '[2141438173, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant2"]' -p registrant2


# Register many diamonds
cleos push action registry1111 regdiamond '[2141438173, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438174, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438175, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438176, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438177, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438178, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438179, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438111, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438112, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438113, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438114, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438115, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438116, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438117, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438118, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438119, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438120, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438121, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438122, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438123, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438125, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438124, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438775, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438126, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438127, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438128, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438129, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438130, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438131, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438132, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438133, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438134, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438135, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438136, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438137, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438138, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438139, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438140, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438141, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438142, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438143, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438144, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438145, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438146, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438147, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438148, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438149, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438150, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438151, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438152, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438153, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438154, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438155, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438156, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438157, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438158, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438159, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438160, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438161, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438162, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438163, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11
cleos push action registry1111 regdiamond '[2141438164, "GIA", "Round Brilliant", 641, 643, 397, 101, "G", "SI1", "Excellent", "Excellent", "Excellent", "None", "registrant11"]' -p registrant11