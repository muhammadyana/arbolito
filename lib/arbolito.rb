require 'bigdecimal'
require 'arbolito/currency/quote'
require 'arbolito/currency/rate'
require "arbolito/version"

module Arbolito

  class << self
    def add_currency_rate(currency_price, from_to_currencies)
      rate = Currency::Rate.new(currency_price, from_to_currencies) 
      store[rate.quote.to_hash] = rate
        
      backwards_rate = rate.backwards
      store[backwards_rate.quote.to_hash] = backwards_rate
    end

    def current_rate(from_to_currencies) 
      store[Currency::Quote.new(from_to_currencies).to_hash].price
    end

    def exchange(money, from_to_currencies)
      quote = Currency::Quote.new(from_to_currencies)

      store[quote.to_hash].convert(money)
    end

    def store
      @@store ||= {}
    end
  end
end
