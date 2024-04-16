# frozen_string_literal: true

module Sailings
  class ConverterService < BaseService
    parameters do
      required(:sailings).filled(:array)
      required(:rates).filled(:array)
      required(:exchange_rates).filled(:hash)
      optional(:to_currency).maybe(:string)
    end

    def call
      convert_rates_to_currency
    end

    private

    def convert_rates_to_currency
      converted_rates = []
      params[:rates].each do |rate|
        sailing = params[:sailings].find { |s| s['sailing_code'] == rate['sailing_code'] }
        next unless sailing

        departure_date = sailing['departure_date']
        rate_value = rate['rate'].to_f
        currency = rate['rate_currency']
        ex_rates = params[:exchange_rates][departure_date] || {}
        converted_value = convert_currency(rate_value, currency, ex_rates)

        next unless converted_value

        converted_rates << {
          'sailing_code' => rate['sailing_code'],
          'rate' => format('%.2f', converted_value)
        }
      end

      Success(converted_rates)
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
