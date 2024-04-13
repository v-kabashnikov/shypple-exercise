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
      filtered_sailings = filter_sailings_by_ports(sailings, params[:origin_port], params[:destination_port])

      # Apply strategy and leg filtering
      if params[:legs] == '1'
        filtered_sailings = filtered_sailings.select do |s|
          s['origin_port'] == params[:origin_port] && s['destination_port'] == params[:destination_port]
        end
      end

      @search_result = if params[:strategy] == 'cheapest'
                         find_cheapest_sailing(filtered_sailings, converted_rates)
                       elsif params[:strategy] == 'fastest'
                         find_fastest_sailing(filtered_sailings)
                       else
                         filtered_sailings # return all possible sailings if no strategy specified
                       end
    end

    def filter_sailings_by_ports(sailings, origin_port, destination_port)
      sailings.select { |s| s['origin_port'] == origin_port && s['destination_port'] == destination_port }
    end

    def find_cheapest_sailing(sailings, converted_rates)
      # Implement the logic to find the cheapest sailing considering the converted rates
      sailings.min_by { |s| converted_rates.find { |r| r['sailing_code'] == s['sailing_code'] }['rate'].to_f }
    end

    def find_fastest_sailing(sailings)
      # Implement the logic to find the fastest sailing based on duration or another metric
      sailings.min_by { |s| calculate_sailing_duration(s) }
    end

    def calculate_sailing_duration(sailing)
      # Calculate duration based on sailing data, assuming `arrival_date` and `departure_date` are available
      (Date.parse(sailing['arrival_date']) - Date.parse(sailing['departure_date'])).to_i
    end
  end
end
