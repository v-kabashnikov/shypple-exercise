#  frozen_string_literal: true

module Sailings
  class Search < BaseService
    attr_reader :sailings, :rates, :exchange_rates

    parameters do
      required(:origin_port).filled(:string)
      required(:destination_port).filled(:string)
      optional(:max_legs).maybe(:integer)
      optional(:strategy).maybe(included_in?: %w[cheapest fastest])
    end

    def call
      fetch_data
      Success(routes)
    end

    private

    def routes
      return find_cheapest_sailing if params[:strategy] == 'cheapest'
      return find_fastest_sailing if params[:strategy] == 'fastest'

      all_routes
    end

    def fetch_data
      @sailings, @rates, @exchange_rates = MapReduceService.call
    end

    # TODO: refactor service and add Failure
    def all_routes
      RouteFinderService.new(sailings).find_routes(params[:origin_port], params[:destination_port], params[:max_legs])
    end

    def converted_rates
      result = ConverterService.call(sailings:, rates:, exchange_rates:)
      result.success? ? result.value! : Failure(result.failure)
    end

    def find_cheapest_sailing
      all_routes.min_by do |route|
        route.sum { |sailing| converted_rate_for_sailing(sailing) }
      end
    end

    def find_fastest_sailing
      all_routes.min_by do |route|
        route.sum { |sailing| calculate_sailing_duration(sailing) }
      end
    end

    def converted_rate_for_sailing(sailing)
      rate_info = converted_rates.find { |r| r['sailing_code'] == sailing['sailing_code'] }
      rate_info ? rate_info['rate'].to_f : Float::INFINITY
    end

    def calculate_sailing_duration(sailing)
      (Date.parse(sailing['arrival_date']) - Date.parse(sailing['departure_date'])).to_i
    end
  end
end
