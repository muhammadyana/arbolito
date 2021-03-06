require 'bigdecimal'
require 'time'
require 'arbolito/currency/quote'
require 'arbolito/currency/rate'
require 'arbolito/currency/non_expirable_rate'
require 'arbolito/store/memory'
require 'arbolito/exchange/yahoo_finance'
require 'arbolito/exchange/alpha_vantage'
require "arbolito/version"

module Arbolito

  class << self
    def add_currency_rate(currency_price, from_to_currencies)
      rate = Currency::NonExpirableRate.new(currency_price, from_to_currencies) 
      add_to_store(rate)
    end

    def current_rate(from_to_currencies) 
      fetch(Currency::Quote.new(from_to_currencies)).price
    end

    def convert(money, from_to_currencies)
      quote = Currency::Quote.new(from_to_currencies)

      rate = fetch(quote)

      rate.convert(money)
    end

    def settings
      @settings ||= {}
    end

    def set(config_key, value)
      settings[config_key] = value
    end

    private
    def add_to_store(rate)
      store.add(rate)
      store.add(rate.backwards)
    end

    def fetch(quote)
      rate = store.fetch(quote)

      if(!rate || rate.expired?(expiration_time))
        rate = exchange.find_current_rate(quote)

        store.add(rate)
      end

      rate
    end

    def store
      settings[:store] ||= Store::Memory
    end

    def exchange
      settings[:exchange] ||= Exchange::YahooFinance
    end

    def expiration_time
      settings[:expiration_time] ||= 60
    end
  end
end
