# frozen_string_literal: true

class MapReduceService < BaseService
  parameters do
  end

  def call
    read_json
    [@sailings, @rates, @exchange_rates]
  end

  private

  def read_json
    file = File.read('response.json')
    data = JSON.parse(file)
    @sailings = data['sailings']
    @rates = data['rates']
    @exchange_rates = data['exchange_rates']
  end
end
