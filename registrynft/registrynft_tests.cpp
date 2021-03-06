#pragma GCC diagnostic ignored "-Wunused-value"
#include <boost/test/unit_test.hpp>
#include <eosio/testing/tester.hpp>
#include <eosio/chain/abi_serializer.hpp>
//
#include <registrynft/registrynft.abi.hpp>
#include <registrynft/registrynft.wast.hpp>

#include <Runtime/Runtime.h>
#include <fc/variant_object.hpp>
#include <string.h>



using namespace eosio;
using namespace eosio::chain;
using namespace eosio::testing;
using namespace fc;
using namespace std;

using mvo = fc::mutable_variant_object;

typedef uint64_t id_type;
typedef string uri_type;

class registrynft_tester: public tester {
    public:
        registrynft_tester(){
            produce_blocks(2);
            //
            create_accounts({ N(test1), N(test2), N(bcdutoken), N(registrynft) } );
            //
            produce_blocks(2);
            //
            set_code( N(registrynft), registrynft_wast);
            set_abi( N(registrynft), registrynft_abi);
            //
            produce_blocks();
            //
            const auto& accnt = control->db().get<account_object, by_name>(N(registrynft));
            abi_def abi;
	        BOOST_REQUIRE_EQUAL(abi_serializer::to_abi(accnt.abi, abi), true);
            abi_ser.set_abi(abi, abi_serializer_max_time);
        }
        //~registrynft_tester(){}
        //

	    action_result push_action(  const account_name& signer, 
				                    const action_name &name, 
				                    const variant_object &data ) 
	    {   
      	    string action_type_name = abi_ser.get_action_type(name);
      	    action act;
            act.account = N(registrynft);
      	    act.name    = name;
      	    act.data    = abi_ser.variant_to_binary( action_type_name, data, abi_serializer_max_time );
            return base_tester::push_action( std::move(act), uint64_t(signer));
        }


        fc::variant get_stats(const string& symbolname)
        {
            auto symb = eosio::chain::symbol::from_string(symbolname);
            auto symbol_code = symb.to_symbol_code().value;
            vector<char> data = get_row_by_account(N(registrynft), symbol_code, N(stat), symbol_code);
            return data.empty() ? fc::variant() : abi_ser.binary_to_variant("stat", data, abi_serializer_max_time);

        }

        fc::variant get_account(account_name acc, const string& symbolname)
        {
            auto symb = eosio::chain::symbol::from_string(symbolname);
            auto symbol_code = symb.to_symbol_code().value;
            vector<char> data = get_row_by_account(N(registrynft), acc, N(accounts), symbol_code);
            return data.empty() ? fc::variant(): abi_ser.binary_to_variant( "accounts", data, abi_serializer_max_time);

        }

        fc::variant get_token(uint64_t report_num)
        {
            vector<char> data = get_row_by_account( N(registrynft), N(registrynft), N(registrynft), report_num );
	        FC_ASSERT(!data.empty(), "empty token");
            return data.empty() ? fc::variant() : abi_ser.binary_to_variant( "token", data, abi_serializer_max_time );
        }

	    //

        action_result create(const account_name issuer, 
                             string symb,                            
                             const uint16_t price_per_centicarat)
        {
            return push_action( N(registrynft), N(create), mvo()
                ("issuer", issuer)                
                ("symb", symb)
                ("price_per_centicarat", price_per_centicarat)
            );
        }
        //
        action_result issue(const account_name registrant,
                            const uint64_t report_num,
                            const string name,
                            const string lab,
                            const string shape_and_cutting_style,
                            const uint16_t heightx100,
                            const uint16_t widthx100,
                            const uint16_t lengthx100,
                            const uint16_t centicarat,
                            const string color_grade,
                            const string clarity_grade,
                            const string cut_grade,
                            const string polish,
                            const string symmetry,
                            const string flourescence,
                            const asset qty,
                            const string urs)
        {

                return push_action( N(registrynft), N(issue), mvo()
                    ("registrant", registrant)
                    ("report_num", report_num)
                    ("name", name)
                    ("lab", lab)
                    ("shape_and_cutting_style", shape_and_cutting_style)
                    ("heightx100", heightx100)
                    ("widthx100", widthx100)
                    ("lengthx100", lengthx100)
                    ("centicarat", centicarat)
                    ("color_grade", color_grade)
                    ("clarity_grade", clarity_grade)
                    ("cut_grade", cut_grade)
                    ("polish", polish)
                    ("symmetry", symmetry)
                    ("flourescence", flourescence)
                    ("qty", qty)
                    ("urs", urs)
                );
        }


        action_result transfer(account_name from, account_name to, 
                               uint64_t report_num, asset quantity,
                               string memo)
        {
            return push_action( N(registrynft), N(transfer), mvo()
                    ("from", from)
                    ("to", to)
                    ("report_num", report_num)
                    ("quantity",quantity)
                    ("memo", memo)
            );

        }
        //
        abi_serializer abi_ser;
};


BOOST_AUTO_TEST_SUITE(registrynft_tests)
    
    BOOST_FIXTURE_TEST_CASE(create_tests, registrynft_tester) try {
        account_name issuer     = "registrynft";
        uint16_t price_per_cc   = 199;
        //
        produce_blocks(1);
        //
        BOOST_REQUIRE_EQUAL(success(), 
            create( issuer, test_symbol, price_per_cc));

    }FC_LOG_AND_RETHROW()


    BOOST_FIXTURE_TEST_CASE(issue_tests, registrynft_tester) try {

        account_name registrant = "registrynft";
        string  test_symbol     = "BCDU";
        uint16_t test_price_per_cc  = 299;
        //
        auto newtoken = create( registrant, test_symbol, test_price_per_cc);

        // Setup Input Parameters
        uint64_t report_num = 499535;
        string name = "wedding diamonds";
        string lab = "gia";
        string shape_and_cutting_style = "triangle";
        uint16_t heightx100 = 300;
        uint16_t widthx100 = 157;
        uint16_t lengthx100 = 123;
        uint16_t centicarat = 15;
        string color_grade = "Green";
        string clarity_grade = "CLEAR";
        string cut_grade = "Excellent";
        string polish = "Excellent";
        string symmetry = "Excellent";
        string flourescence = "Clear";
        //int64_t amount = 299;
        //asset quantity( amount, symbol(0,"BCDU"));
        string urs = "push action test1";
        //
        //produce_blocks(1);
        //
        BOOST_REQUIRE_EQUAL(success(),
                    issue( registrant, report_num, name, lab, shape_and_cutting_style, heightx100, 
                    widthx100, lengthx100, centicarat, color_grade, clarity_grade, cut_grade, polish, 
                    symmetry, flourescence, asset::from_string("299 BCDU"), urs));
    }FC_LOG_AND_RETHROW()
    

    BOOST_FIXTURE_TEST_CASE(transfer_tests, registrynft_tester) try {

        account_name registrant = "registrynft";
        string  test_symbol     = "BCDU";
        uint16_t test_price_per_cc  = 399;
        auto newtoken = create( registrant, test_symbol, test_price_per_cc);
        //
        //produce_blocks(1);

        // Setup Input Parameters
        uint64_t report_num = 699202;
        string name = "wedding diamonds";
        string lab = "gia";
        string shape_and_cutting_style = "triangle";
        uint16_t heightx100 = 300;
        uint16_t widthx100 = 157;
        uint16_t lengthx100 = 123;
        uint16_t centicarat = 15;
        string color_grade = "Green";
        string clarity_grade = "CLEAR";
        string cut_grade = "Excellent";
        string polish = "Excellent";
        string symmetry = "Excellent";
        string flourescence = "Clear";
        //int64_t amount = 299;
        //asset quantity( amount, symbol(0,"BCDU"));
        string urs = "push action test1";


        auto result =  issue( registrant, report_num, name, lab, shape_and_cutting_style, heightx100, 
                    widthx100, lengthx100, centicarat, color_grade, clarity_grade, cut_grade, polish, 
                    symmetry, flourescence, asset::from_string("399 BCDU"), urs);

        account_name from = "registrynft";
        account_name to = "bcdutoken";
        string memo("transfer_test testcase for 99 BCDU tokens");
        //
        BOOST_REQUIRE_EQUAL(success(), transfer( from, to, report_num, asset::from_string("99 BCDU"), memo));
    }FC_LOG_AND_RETHROW()


BOOST_AUTO_TEST_SUITE_END()