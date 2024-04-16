# frozen_string_literal: true

module Sailings
  class Search < BaseService
    include Dry::Monads[:result, :do]

    parameters do
      required(:origin_port).filled(:string)
      required(:destination_port).filled(:string)
      optional(:max_legs).maybe(:integer)
      optional(:strategy).maybe(included_in?: %w[cheapest fastest])
    end

    def call
      data = yield fetch_sailing_data
      sailings, rates, exchange_rates = data.values_at(:sailings, :rates, :exchange_rates)
      routes = yield find_routes(sailings)
      converted_rates = yield convert_sailing_rates(sailings, rates, exchange_rates)
      apply_strategy(routes, converted_rates)
    end

    private

    def fetch_sailing_data
      MapReduceService.call
    end

    def find_routes(sailings)
      RouteFinderService.call(sailings:, origin_port: params[:origin_port],
                              destination_port: params[:destination_port], max_legs: params[:max_legs])
    end

    def convert_sailing_rates(sailings, rates, exchange_rates)
      ConverterService.call(sailings:, rates:, exchange_rates:)
    end

    def apply_strategy(routes, converted_rates)
      case params[:strategy]
      when 'cheapest'
        Success(find_cheapest_sailing(routes, converted_rates))
      when 'fastest'
        Success(find_fastest_sailing(routes))
      else
        Success(routes)
      end
    end

    def find_cheapest_sailing(routes, converted_rates)
      routes.min_by do |route|
        route.sum { |sailing| converted_rate_for_sailing(sailing, converted_rates) }
      end
    end

    def find_fastest_sailing(routes)
      routes.min_by do |route|
        route.sum { |sailing| calculate_sailing_duration(sailing) }
      end
    end

    def converted_rate_for_sailing(sailing, converted_rates)
      rate_info = converted_rates.find { |r| r['sailing_code'] == sailing['sailing_code'] }
      rate_info ? rate_info['rate'].to_f : Float::INFINITY
    end

    def calculate_sailing_duration(sailing)
      (Date.parse(sailing['arrival_date']) - Date.parse(sailing['departure_date'])).to_i
    end
  end
end
