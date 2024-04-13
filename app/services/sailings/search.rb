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
        perform_search
        @search_result = "Simulated search result for #{params[:origin_port]} to #{params[:destination_port]}"
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

    def perform_search
      sailings, rates, exchange_rates = MapReduceService.call
      exchange_converter = ConverterService.new(exchange_rates)
      converted_rates = exchange_converter.to_usd(rates, sailings)
      # build routes
    end
  end
end
