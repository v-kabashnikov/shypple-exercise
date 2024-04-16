# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sailings::CurrencyConverter, type: :service do
  let(:data) { JSON.parse(File.read('response.json')) }
  let(:exchange_rates) { data['exchange_rates'] }
  let(:sailings) { data['sailings'] }
  let(:rates) { data['rates'] }

  subject { described_class.call(sailings:, rates:, exchange_rates:) }

  describe '#to_usd' do
    context 'when exchange rates are present' do
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

    context 'when exchange rates are not present' do
      let(:exchange_rates) do
        {
          "2025-01-11": {
            "zzz": 1.1138,
            "xxx": 130.85
          },
          "2025-11-11": {
            "yyy": 1.1138,
            "ooo": 132.97
          }
        }
      end

      it 'returns a failure' do
        expect(subject).to be_failure
        expect(subject.failure).to eq('Exchange rates not found')
      end
    end
  end
end
