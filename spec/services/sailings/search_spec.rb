# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sailings::Search, type: :service do
  let(:data) { JSON.parse(File.read('response.json')) }
  let(:sailings) { data['sailings'] }
  let(:rates) { data['rates'] }
  let(:exchange_rates) { data['exchange_rates'] }

  subject { described_class.call('CNSHA', 'NLRTM', 'cheapest') }

  describe '#call' do
    context 'when parameters are valid' do
      # it 'fetches data and performs search based on the strategy' do
      #   expect(subject.call).to be_truthy
      #   expect(subject.success?).to be true
      # end

      it 'returns the direct sailing when legs are 1' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', max_legs: 1)
        expect(search.value!).to match_array([[{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01', 'sailing_code' => 'ABCD' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-02',
                                                 'arrival_date' => '2022-03-02', 'sailing_code' => 'EFGH' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-31',
                                                 'arrival_date' => '2022-02-28', 'sailing_code' => 'IJKL' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-30',
                                                 'arrival_date' => '2022-03-05', 'sailing_code' => 'MNOP' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-29',
                                                 'arrival_date' => '2022-02-15', 'sailing_code' => 'QRST' }]])
      end

      it 'returns the cheapest direct sailing when legs are 1' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', max_legs: 1,
                                      strategy: 'cheapest')
        expect(search.value!).to match_array([{ 'arrival_date' => '2022-03-05', 'departure_date' => '2022-01-30',
                                                'destination_port' => 'NLRTM', 'origin_port' => 'CNSHA', 'sailing_code' => 'MNOP' }])
      end

      it 'returns the fastest direct sailing when legs are 1' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', max_legs: 1,
                                      strategy: 'fastest')
        expect(search.value!).to match_array([{ 'arrival_date' => '2022-02-15', 'departure_date' => '2022-01-29',
                                                'destination_port' => 'NLRTM', 'origin_port' => 'CNSHA', 'sailing_code' => 'QRST' }])
      end

      it 'returns all sailings between ports when no legs param' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM')
        expect(search.value!).to match_array([[{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01', 'sailing_code' => 'ABCD' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-02',
                                                 'arrival_date' => '2022-03-02', 'sailing_code' => 'EFGH' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-31',
                                                 'arrival_date' => '2022-02-28', 'sailing_code' => 'IJKL' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-30',
                                                 'arrival_date' => '2022-03-05', 'sailing_code' => 'MNOP' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM', 'departure_date' => '2022-01-29',
                                                 'arrival_date' => '2022-02-15', 'sailing_code' => 'QRST' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'ESBCN', 'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-12', 'sailing_code' => 'ERXQ' },
                                               { 'origin_port' => 'ESBCN', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-15',
                                                 'arrival_date' => '2022-03-29', 'sailing_code' => 'ETRF' }],
                                              [{ 'origin_port' => 'CNSHA', 'destination_port' => 'ESBCN', 'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-12', 'sailing_code' => 'ERXQ' },
                                               { 'origin_port' => 'ESBCN', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-16',
                                                 'arrival_date' => '2022-02-20', 'sailing_code' => 'ETRG' }]])
      end

      it 'returns the cheapest sailing when no legs param' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', strategy: 'cheapest')
        expect(search.value!).to match_array([{ 'arrival_date' => '2022-02-12', 'departure_date' => '2022-01-29', 'destination_port' => 'ESBCN', 'origin_port' => 'CNSHA', 'sailing_code' => 'ERXQ' },
                                              { 'origin_port' => 'ESBCN', 'destination_port' => 'NLRTM', 'departure_date' => '2022-02-16',
                                                'arrival_date' => '2022-02-20', 'sailing_code' => 'ETRG' }])
      end

      it 'returns the fastest sailing when no legs param' do
        search = described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', strategy: 'fastest')
        expect(search.value!).to match_array([{ 'arrival_date' => '2022-02-15', 'departure_date' => '2022-01-29',
                                                'destination_port' => 'NLRTM', 'origin_port' => 'CNSHA', 'sailing_code' => 'QRST' }])
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { origin_port: nil, destination_port: 'NLRTM' } }

      it 'returns invalid params' do
        search = described_class.call(origin_port: nil, destination_port: nil, strategy: 'fas')
        expect(search.failure).to eq({ origin_port: ['must be filled'],
                                       destination_port: ['must be filled'],
                                       strategy: ['must be one of: cheapest, fastest'] })
      end
    end
  end
end
