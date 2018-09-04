#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/currency.hpp>

#include <string>
#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/types.hpp>
#include <eosiolib/action.hpp>
#include <eosiolib/symbol.hpp>
#include <eosiolib/crypto.h>

#include <string>

using namespace eosio;
using std::string;

class registry: public contract {

public:
  registry(account_name self): contract (self) {}

  // @abi action
  void regdiamond ( const uint64_t          report_num,
                    const string            lab,
                    const string            shape_and_cutting_style,
                    const uint16_t          heightx100,
                    const uint16_t          widthx100,
                    const uint16_t          lengthx100,
                    const uint16_t          centicarat,
                    const string            color_grade,
                    const string            clarity_grade,
                    const string            cut_grade,
                    const string            polish,
                    const string            symmetry,
                    const string            flourescence,
                    const account_name      registrant);
  

  // @abi action
  void addclaritych ( const uint64_t        report_num,
                      const string          clarity_characteristic);

  // @abi action 
  void addinscript  ( const uint64_t        report_num,
                      const string          inscription);
  
  // @abi action
  void addcomment   ( const uint64_t        report_num,
                      const string          comment);

  // @abi action
  void addconfig    ( const account_name    registry_token,
                      const string          symbol,
                      const uint8_t         precision,
                      const uint16_t        price_per_centicaratx100);


private:

  // @abi table configs i64
  struct config {
    uint64_t          config_id;
    account_name      registry_token;
    symbol_type       registry_symbol;
    uint16_t          price_per_centicaratx100;

    uint64_t  primary_key () const { return config_id; }
    EOSLIB_SERIALIZE (config, (config_id)(registry_token)(registry_symbol)(price_per_centicaratx100))
  };

  typedef multi_index<N(configs), config> config_table;

  // @abi table diamonds i64
  struct diamond {
    uint64_t          report_num;
    string            lab;
    string            shape_and_cutting_style;
    uint16_t          heightx100;
    uint16_t          widthx100;
    uint16_t          lengthx100;
    uint16_t          centicarat;
    string            color_grade;
    string            clarity_grade;
    string            cut_grade;
    string            polish;
    string            symmetry;
    string            flourescence;
    vector<string>    clarity_characteristics;
    vector<string>    inscriptions;
    vector<string>    comments;
    account_name      registrant;
    

    uint64_t primary_key() const { return report_num; }

    EOSLIB_SERIALIZE (diamond, (report_num)(lab)(shape_and_cutting_style)
                  (heightx100)(widthx100)(lengthx100)(centicarat)(color_grade)(clarity_grade)
                  (cut_grade)(polish)(symmetry)(flourescence)(clarity_characteristics)
                  (inscriptions)(comments)(registrant))
  };

  typedef multi_index<N(diamonds), diamond> diamond_table;

void transfer(const account_name from,
                  const account_name to,
                  const asset token_amount,
                  const string memo)
    {

        if (from == to) return;

        config_table config(_self, _self);
        auto itr = config.begin();
        eosio_assert(itr != config.end(), "Configuration is not set.");

        print("---------- Transfer -----------\n");
        print("Token Contract   :", name{itr->registry_token}, "\n");
        print("From             :", name{from}, "\n");
        print("To               :", name{to}, "\n");
        print("Amount           :", token_amount, "\n");
        print("Memo             :", memo, "\n");

        action(
            permission_level{from, N(active)},
            itr->registry_token, N(transfer),
            std::make_tuple(from, to, token_amount, memo))
            .send();

        print("---------- End Transfer -------\n");
    }
};

EOSIO_ABI(registry, (regdiamond)(addclaritych)(addinscript)(addcomment)(addconfig))
