#  frozen_string_literal: true

module Sailings
  class Search < BaseService
    attr_reader :params, :errors, :search_result

    def initialize(params)
      @params = params
      @errors = []
      @search_result = nil
    end

    def call
      if params_valid?
        sailings, rates, exchange_rates = MapReduceService.call
        converted_rates = ConverterService.new(exchange_rates).to_usd(rates, sailings)
        perform_search(sailings, converted_rates)
      else
        @errors << 'Invalid search parameters'
      end
    end

    def success?
      @errors.empty?
    end

    def result
      @search_result
    end

    private

    def params_valid?
      params[:origin_port].present? && params[:destination_port].present?
    end

    def perform_search(sailings, converted_rates)
      route_finder = SailingRouteFinderService.new(sailings)

      all_routes = route_finder.find_route(params[:origin_port], params[:destination_port], max_legs: params[:max_legs])

      @search_result = if params[:strategy] == 'cheapest'
                         find_cheapest_sailing(all_routes, converted_rates)
                       elsif params[:strategy] == 'fastest'
                         find_fastest_sailing(all_routes)
                       else
                         all_routes # return all possible sailings if no strategy specified
                       end

      self
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
