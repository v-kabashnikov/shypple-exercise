# frozen_string_literal: true

class MapReduceClient < BaseService
  parameters do
  end

  def call
    read_json
  end

  private

  def read_json
    file = File.read('response.json')
    data = JSON.parse(file)
    Success(sailings: data['sailings'], rates: data['rates'], exchange_rates: data['exchange_rates'])
  end
end
