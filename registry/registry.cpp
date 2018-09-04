#include <registry.hpp>
#include <iostream>
#include <functional>
#include <string>

using namespace std;
using namespace eosio;


void registry::addconfig    ( const account_name    registry_token,
                      const string          symbol,
                      const uint8_t         precision,
                      const uint16_t        price_per_centicaratx100) {

   config_table c_t (_self, _self);
   c_t.emplace (_self, [&](auto &c) {
     c.config_id                = c_t.available_primary_key();
     c.registry_token           = registry_token;
     c.registry_symbol          = string_to_symbol (precision, symbol.c_str());
     c.price_per_centicaratx100 = price_per_centicaratx100;
   });
}

void registry::regdiamond(const uint64_t report_num,
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
                          const account_name registrant)

{

  //require_auth(registrant);

  diamond_table diamond(_self, _self);

  auto d_itr = diamond.find(report_num);
  eosio_assert(d_itr == diamond.end(), "Report number already exists.");

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
    d.registrant = registrant;
  });

  config_table config(_self, _self);
  auto c_itr = config.begin();
  eosio_assert(c_itr != config.end(), "Configuration is not set.");

  asset register_cost = asset {c_itr->price_per_centicaratx100 * centicarat, c_itr->registry_symbol};
  transfer (registrant, _self, register_cost, to_string(report_num));

  print(report_num, " diamond created.");
}

void registry::addclaritych(const uint64_t report_num,
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

void registry::addinscript(const uint64_t report_num,
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

void registry::addcomment(const uint64_t report_num,
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
