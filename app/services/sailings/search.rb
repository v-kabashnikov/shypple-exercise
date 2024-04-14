#  frozen_string_literal: true

module Sailings
  class Search < BaseService
    attr_reader :origin_port, :destination_port, :max_legs, :strategy, :sailings, :rates, :exchange_rates

    def initialize(origin_port, destination_port, max_legs = nil, strategy = nil)
      @origin_port = origin_port
      @destination_port = destination_port
      @max_legs = max_legs
      @strategy = strategy
      @sailings, @rates, @exchange_rates = MapReduceService.call
    end

    def call
      return nil unless params_valid?

      return all_routes unless strategy

      return find_cheapest_sailing(all_routes, converted_rates) if strategy == 'cheapest'

      return find_fastest_sailing(all_routes) if strategy == 'fastest'

      nil
    end

    private

    def all_routes
      RouteFinderService.new(sailings).find_routes(origin_port, destination_port,
                                                   max_legs:)
    end

    def converted_rates
      ConverterService.call(sailings, rates, exchange_rates)
    end

    def params_valid?
      origin_port.present? && destination_port.present?
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
