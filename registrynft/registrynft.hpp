#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/currency.hpp>

//#include <string>
#include <eosiolib/eosio.hpp>
#include <eosiolib/asset.hpp>
#include <eosiolib/types.hpp>
#include <eosiolib/action.hpp>
#include <eosiolib/symbol.hpp>
#include <eosiolib/crypto.h>
#include <string>
//#include <bcdutoken.hpp>


using namespace eosio;
using std::string;
typedef uint64_t id_type;
typedef string uri_type;

namespace eosiosystem
{
  class system_contract;
}

// bcdu token forward class decl.
//class bcdutoken;

class registrynft: public contract {
  public:
    registrynft(account_name self):contract(self), registry_status{PENDING} {}
    ~registrynft(){}

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
    void create(const account_name issuer, 
                const string symb,
                const uint16_t price_per_centicarat);
    
    // @abi action
    void issue(const account_name registrant,
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
                const string urs);

      // @abi action
      void transfer(account_name from, account_name to, uint64_t report_num, asset quantity, string memo);

      // @abi action
      void burn(const account_name owner, const uint64_t report_num);
      
      
      void setrampayer(account_name payer, uint64_t report_num);
      
      void transferReceived(const currency::transfer &transfer, const account_name code);
      
      void apply(const account_name contract, const account_name action);

      // @abi table accounts i64
      struct account
      {
          asset balance;
          account_name token_contract;
          uint64_t primary_key() const {return balance.symbol.name();}
      };

      // @abi table stat i64
      struct stats
      {
          asset supply;
          account_name issuer;
          uint16_t price_per_centicarat;
          //
          uint64_t primary_key() const {return supply.symbol.name();}
          account_name get_issuer() const {return issuer;}
          asset get_supply() const {return supply;}
      };
      //        
  private:
    enum
    {
          PENDING = 1,
          CREATED,
          ISSUED,
          TRANSFER,
          TRANSFERRED,
          FINALIZED
    };

    int registry_status;

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
      uint32_t          registration_date;
      asset             registration_cost;
      uint8_t           registration_status;
      string            name;
      account_name      owner;
      uri_type          uri;
      asset             value;
      //
      uint64_t primary_key() const { return report_num; }
      account_name get_owner() const {return owner;}
      string get_uri() const {return uri;}
      asset get_value() const {return value;}
      uint64_t get_symbol() const { return value.symbol.name();}
      uint64_t get_name() const {return string_to_name(name.c_str());}



      EOSLIB_SERIALIZE (diamond, (report_num)(lab)(shape_and_cutting_style)
                    (heightx100)(widthx100)(lengthx100)(centicarat)(color_grade)(clarity_grade)
                    (cut_grade)(polish)(symmetry)(flourescence)(clarity_characteristics)
                    (inscriptions)(comments)(registrant)(registration_date)(registration_cost)(registration_status)
                    (name)(owner)(uri)(value))
    };

    //typedef multi_index<N(diamonds), diamond> diamond_table;
    typedef multi_index<N(diamonds), diamond> diamond_table;

    //
    //using account_index = eosio::multi_index<N(accounts), account>;
    typedef eosio::multi_index<N(accounts), account> account_index;

    using currency_index = eosio::multi_index<N(stat), stats, indexed_by<N(byissuer), const_mem_fun<stats, account_name, &stats::get_issuer>>>;

    //using diamond_index = eosio::multi_index<N(diamond), diamond,
    //                                       indexed_by<N(byowner), const_mem_fun<diamond, account_name, &diamond::get_owner>>,
    //                                       indexed_by<N(bysymbol), const_mem_fun<diamond, uint64_t, &diamond::get_symbol>>,
    //                                       indexed_by<N(byname), const_mem_fun<diamond, uint64_t, &diamond::get_name>>>;

  private:
    friend eosiosystem::system_contract;
    //
    // diamond_index diamonds;
    void sub_balance(account_name owner, asset value);
    void add_balance(account_name owner, asset value, account_name ram_payer);
    void sub_supply(asset quantity);
    void add_supply(asset quantity);
    void mint(account_name owner, account_name ram_payer, asset value, string uri, string name);
 
};
