# frozen_string_literal: true

module Sailings
  class ConverterService < BaseService
    attr_reader :sailings, :rates, :exchange_rates

    def initialize(sailings, rates, exchange_rates, to_currency = nil)
      @sailings = sailings
      @rates = rates
      @exchange_rates = exchange_rates
      @to_currency = to_currency || 'USD'
    end

    def call
      convert_rates_to_currency
    end

    private

    def convert_rates_to_currency
      converted_rates = []
      rates.each do |rate|
        sailing = sailings.find { |s| s['sailing_code'] == rate['sailing_code'] }
        next unless sailing

        departure_date = sailing['departure_date']
        rate_value = rate['rate'].to_f
        currency = rate['rate_currency']
        ex_rates = exchange_rates[departure_date] || {}
        converted_value = convert_currency(rate_value, currency, ex_rates)

        next unless converted_value

        converted_rates << {
          'sailing_code' => rate['sailing_code'],
          'rate' => format('%.2f', converted_value)
        }
      end

      converted_rates
    end

    def convert_currency(rate_value, currency, ex_rates)
      case currency
      when 'USD'
        rate_value
      when 'EUR'
        rate_value * (ex_rates['usd'] || 1)
      when 'JPY'
        rate_value * (1 / (ex_rates['jpy'] || 1)) * (ex_rates['usd'] || 1)
      end
    end
  end
end
