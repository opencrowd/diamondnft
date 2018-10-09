#pragma GCC diagnostic ignored "-Wunused-parameter"
//#pragma once
#include "registrynft.hpp"
#include <iostream>
#include <functional>
#include <string>

using namespace std;
using namespace eosio;


void registrynft::create(const account_name issuer,
                         const string symb,
                         const uint16_t price_per_centicarat)
                         
{
    require_auth(issuer);
    eosio_assert(is_account(issuer), "Issuer does not exist");
    eosio_assert(registry_status == PENDING, "diamond registry already created!!");
    //
    asset supply(0, string_to_symbol(0, symb.c_str()));
    auto symbol = supply.symbol; 
    print("\n");
    print("asset-symbol:",symb);
    print("\n");
    print("captured-symbol:", symbol);
    eosio_assert(symbol.is_valid(), "invalid symbol name!!");
    eosio_assert(supply.is_valid(), "invalid supply!!");

    // Check if currency with symbol already exists
    currency_index currency_table(_self, symbol.name() );
    auto existing_currency = currency_table.find(symbol.name());
    eosio_assert(existing_currency == currency_table.end(), "token with symbol already exists");
    //
    // Create new currency
    currency_table.emplace(_self, [&](auto &currency){
        currency.supply = supply;
        currency.issuer = issuer;
        currency.price_per_centicarat = price_per_centicarat;
    });
    registry_status = CREATED;
    print("\n");
    print("diamond created..."); 
}

void registrynft::issue(const account_name registrant, 
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
    
    require_auth(_self);

    // Check if registrant account exists
    eosio_assert(is_account(registrant), "registrant account does not exist!!");
    
    vector<string> uris;
    uris.push_back(urs);

    // capture symbol
   
    print("using asset-amount: ",qty.amount);
    print("using asset-symbol: ",qty.symbol);
    symbol_type symbol = qty.symbol;
    //
    eosio_assert(qty.is_valid(), "invalid asset type");
    eosio_assert(symbol.precision() == 0, "quantity must be whole number");
    eosio_assert(name.size() <= 32, "name has more than 32 bytes");
    eosio_assert(name.size() > 0, "name is empty");
    eosio_assert(qty.amount > 0, "must issue positive quantities of NFTs");

    diamond_table diamond(_self, _self);
    auto d_itr = diamond.find(report_num);
    eosio_assert(d_itr == diamond.end(), "Report number already exists.");

    // ensure currecy instrument object has been created
    auto symbol_name = symbol.name();
    print("symbol_name: ", symbol_name);
    currency_index currency_table(_self, symbol_name);
    auto existing_currency = currency_table.find(symbol_name);
    eosio_assert(existing_currency != currency_table.end(), "token with symbol does not exist, create token before issue");
    const auto& st = *existing_currency;
    eosio_assert(symbol == st.supply.symbol, "symbol precision mismatches!!");
    //
    // update registry status
    registry_status = ISSUED;
    //
    diamond.emplace(_self, [&](auto &d) {
        d.report_num = report_num;
        d.lab = lab;
        d.shape_and_cutting_style = shape_and_cutting_style;
        d.heightx100 = heightx100;
        d.widthx100 = widthx100;
        d.lengthx100 = lengthx100;
        d.centicarat = centicarat;
        d.color_grade = color_grade;
        d.clarity_grade = clarity_grade;
        d.cut_grade = cut_grade;
        d.polish = polish;
        d.symmetry = symmetry;
        d.flourescence = flourescence;
        d.clarity_characteristics.push_back(string("NA"));
        d.inscriptions.push_back(string("NA"));
        d.comments.push_back(string("NA"));
        d.registrant = registrant;
        d.registration_date = now();
        d.registration_cost = asset {st.price_per_centicarat * centicarat, qty.symbol};
        d.name = name;
        d.owner = _self;
        d.uri = urs;
        d.value = qty;
        d.registration_status = registry_status;
    });
    //

    // increase supply
    add_supply(qty);

    // check the number of tokens matches uri size
    //eosio_assert(qty.amount == uris.size(), "mismatch between number of tokens and uris size provided!!");

    // Mint nfts
    for(auto const &uri : uris)
       mint(registrant, st.issuer, asset{1,symbol}, uri, name);

    // Add balance to account
    add_balance(registrant, qty, st.issuer);

    eosio_assert(registry_status == ISSUED, "diamond registration status is not ISSUED!!");
    print("diamond issued & registered ");
    print("\n");
    print("Asset(diamond) issued, registration status: ", registry_status);
}


void registrynft::transfer(account_name from, account_name to, uint64_t report_num, asset quantity, string memo)
{

    print("registrynft:transfer() received");

    // Ensure authorized to send from account
    eosio_assert(from != to, "cannot transfer to self");
    require_auth(from);

    // Ensure 'to' account exists
    eosio_assert(is_account(to), "to account does not exist");

    // Check memo size and print
    eosio_assert(memo.size() <= 256, "memo has more than 256 bytes");

    // Ensure token ID exists
    diamond_table diamond(_self, _self);
    auto sender_token = diamond.find(report_num);
    const auto &st = *sender_token;
    eosio_assert(sender_token != diamond.end(), "token with specified ID does not exist");
    eosio_assert(sender_token->owner == from, "sender does not own token with specified ID");
    //
    print("sender-token-name:", st.name);
    print("sender-token-value", st.value.symbol);
    print("sender-token-value", st.value.amount);

    // Notify both recipients
    require_recipient(from);
    require_recipient(to);

    // Transfer NFT from sender to receiver
    diamond.modify(st, from, [&](auto &d) {
        d.owner = to;
    });

    // Change balance of both accounts
    sub_balance(from, quantity);
    add_balance(to, quantity, from);
}


void registrynft::burn(const account_name owner, const uint64_t report_num)
{
    require_auth(owner);

    // Find diamond to burn
    //auto burn_diamond = diamonds.find(report_num);
    diamond_table diamonds(_self, _self);
    auto burn_diamond = diamonds.find(report_num);
    eosio_assert(burn_diamond != diamonds.end(), "diamond with report-num does not exist!!");
    eosio_assert(burn_diamond->owner == owner,  "diamond not owned by account!!");

    asset burnt_supply = burn_diamond->value;
    //asset burnt_supply;

    // remove tokens from table
    diamonds.erase(burn_diamond);

    // lower balance from owner
    sub_balance(owner, burnt_supply);

    //lower supply from currency
    sub_supply(burnt_supply);
}


void registrynft::setrampayer(account_name payer, uint64_t report_num)
{
    require_auth(payer);
    //
    // Ensure tokenId exists
    diamond_table diamond(_self, _self);
    auto payer_token = diamond.find(report_num);
    eosio_assert(payer_token != diamond.end(), "token with report-number does not exist!!");
    //
    // ensure payer owns token
    eosio_assert(payer_token->owner == payer, "payer does not own token with specified ID");
    const auto& st = *payer_token;

    // notify player
    require_recipient(payer);
    //
    diamond.erase(payer_token);
    diamond.emplace(payer, [&](auto& d){
        d.report_num = st.report_num;
        d.uri = st.uri;
        d.owner = st.owner;
        d.value = st.value;
        d.name = st.name;
    });
}

void registrynft::mint(account_name owner, account_name ram_payer, asset value, string uri, string name)
{

    diamond_table diamond(_self, _self);
    // auto mint_token = diamond.find(report_num);
    // 
    //eosio_assert(mint_token != diamond.end(), "diamond_token not found for supplied report number!!");
    //
    diamond.emplace(ram_payer, [&](auto& d){
        d.report_num = diamond.available_primary_key();
        d.uri = uri;
        d.owner = owner;
        d.value = value;
        d.name = name;
    }); 
}

void registrynft::addclaritych(const uint64_t report_num,
                            const string clarity_characteristic)
{

  // should we require registrant permission ?
  diamond_table diamond(_self, _self);

  auto itr = diamond.find(report_num);
  eosio_assert(itr != diamond.end(), "Report number does not exist.");

  diamond.modify(itr, _self, [&](auto &d) {
    d.clarity_characteristics.push_back(clarity_characteristic);
  });
}

void registrynft::addinscript(const uint64_t report_num,
                           const string inscription)
{

  // should we require registrant permission ?
  diamond_table diamond(_self, _self);

  auto itr = diamond.find(report_num);
  eosio_assert(itr != diamond.end(), "Report number does not exist.");

  diamond.modify(itr, _self, [&](auto &d) {
    d.inscriptions.push_back(inscription);
  });
}

void registrynft::addcomment(const uint64_t report_num,
                          const string comment)
{
  // should we require registrant permission ?
  diamond_table diamond(_self, _self);

  auto itr = diamond.find(report_num);
  eosio_assert(itr != diamond.end(), "Report number does not exist.");

  diamond.modify(itr, _self, [&](auto &d) {
    d.comments.push_back(comment);
  });
}

void registrynft::add_balance(account_name owner, asset value, account_name ram_payer)
{
    account_index to_accounts(_self, owner);
    auto to = to_accounts.find(value.symbol.name());
    //
    if (to == to_accounts.end())
    {
        print("Adding to Balance, Value: ", value);
        to_accounts.emplace(ram_payer, [&](auto &a) {
            a.balance = value;
        });
    }
    else
    {
        print("Accruing Balance with value: ", value);
        to_accounts.modify(to, 0, [&](auto &a) {
            a.balance += value;
        });
    }

}

void registrynft::sub_balance(account_name owner, asset value)
{
    print("symbol-name: ", value.symbol.name());
    print("symbol-value:", value.amount);
    //
    account_index from_acnts(_self, owner);
    const auto& from = from_acnts.get(value.symbol.name(), "no balance object found");
    eosio_assert(from.balance.amount >= value.amount, "overdrawn balance");

    if (from.balance.amount == value.amount)
    {
        from_acnts.erase(from);
    }
    else
    {
        from_acnts.modify(from, owner, [&](auto &a) {
            a.balance -= value;
        });
    }  
}


void registrynft::sub_supply(asset quantity)
{
    auto symbol_name = quantity.symbol.name();
    currency_index currency_table(_self, symbol_name);
    auto current_currency = currency_table.find(symbol_name);

    currency_table.modify(current_currency, 0, [&](auto &currency) {
        currency.supply -= quantity;
    });
}

void registrynft::add_supply(asset quantity)
{
    auto symbol_name = quantity.symbol.name();
    currency_index currency_table(_self, symbol_name);
    auto current_currency = currency_table.find(symbol_name);
    print("symbol-name is: ", symbol_name);
    eosio_assert(current_currency != currency_table.end(), "currency not found for symbol-name");

    currency_table.modify(current_currency, 0, [&](auto &currency) {
        currency.supply += quantity;
    });
}


void registrynft::apply(const account_name contract, const account_name action_type)
{
    if( contract == _self)
    {
        auto &thiscontract = *this;

        switch(action_type)
        {
            EOSIO_API(registrynft, (create)(issue)(transfer)(addclaritych)(addinscript)(addcomment))
        };
    }
    else
    {
        if (action_type == N(transfer))
        {
            //print("transfer--notify() received in registrynft");
            //print("contract:", contract_code, "act: ", action_type);
            transferReceived(unpack_action_data<currency::transfer>(), contract); 
        }
    }
    
}

void registrynft::transferReceived(const currency::transfer &transfer, const account_name code)
{
    // validate transfer.from is not the same as transfer.to
    eosio_assert(transfer.from != transfer.to, "Error: transfer.from and transfer.to account cannot be the same!!");
    //
    print("Account Name     :   ", name{code}, "\n");
    print("From             :   ", name{transfer.from}, "\n");
    print("To               :   ", name{transfer.to}, "\n");
    print("Asset            :   ", transfer.quantity, "\n");
    print("Received Amount  :   ", transfer.quantity.amount, "\n");
    print("Received Symbol  :   ", transfer.quantity.symbol, "\n");
    print("Memo             :   ", transfer.memo, "\n");
    //
    auto symbol_name = transfer.quantity.symbol.name();
    account_index accounts_table(_self, symbol_name);
    auto acct_iter = accounts_table.find(symbol_name);
    asset new_balance;
    print("Available Balance  : ", acct_iter->balance, "\n");
    //
    if(acct_iter != accounts_table.end())
    {
        eosio_assert(acct_iter->token_contract == code, "Transfer does not match existing token contract");
        accounts_table.modify(acct_iter, transfer.from, [&](auto &bal) {
            bal.balance += transfer.quantity;
            new_balance = bal.balance;
        });
    }
    else
    {
        accounts_table.emplace(transfer.from, [&](auto& bal){
            bal.balance = transfer.quantity;
            bal.token_contract = code;
            new_balance = transfer.quantity;
        });
    }
    //
    print(name{transfer.from}, " deposited:     ", transfer.quantity, "\n");
    print(name{transfer.from}, " funds available", new_balance);
 
}


extern "C"
{
    //using namespace bay;
    using namespace eosio;

    void apply(uint64_t receiver, uint64_t code, uint64_t action)
    {
        auto self = receiver;
        registrynft contract(self);
        contract.apply(code, action);
        eosio_exit(0);
    }
}

//EOSIO_ABI(registrynft,(create)(issue)(transfer)(setrampayer)(burn)(addclaritych)(addinscript)(addcomment))
