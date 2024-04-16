# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sailings::CurrencyConverter, type: :service do
  let(:data) { JSON.parse(File.read('response.json')) }
  let(:exchange_rates) { data['exchange_rates'] }
  let(:sailings) { data['sailings'] }
  let(:rates) { data['rates'] }

  subject { described_class.call(sailings:, rates:, exchange_rates:) }

  describe '#to_usd' do
    it 'converts rates to USD' do
      expect(subject.value!).to match_array([
                                       { 'sailing_code' => 'ABCD', 'rate' => '589.30' },
                                       { 'sailing_code' => 'EFGH', 'rate' => '1008.11' },
                                       { 'sailing_code' => 'IJKL', 'rate' => '828.65' },
                                       { 'sailing_code' => 'MNOP', 'rate' => '456.78' },
                                       { 'sailing_code' => 'QRST', 'rate' => '848.67' },
                                       { 'sailing_code' => 'ERXQ', 'rate' => '291.77' },
                                       { 'sailing_code' => 'ETRF', 'rate' => '70.96' },
                                       { 'sailing_code' => 'ETRG', 'rate' => '69.96' },
                                       { 'sailing_code' => 'ETRB', 'rate' => '439.96' }
                                     ])
    end
  end
end
