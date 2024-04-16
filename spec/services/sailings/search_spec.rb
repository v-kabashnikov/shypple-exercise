# frozen_string_literal: true

require 'rails_helper'
include Dry::Monads[:result]

RSpec.describe Sailings::Search, type: :service do
  let(:routes) do
    [
      [{ 'sailing_code' => 'ABCD', 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
         'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01' }],
      [{ 'sailing_code' => 'EFGH', 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
         'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02' }],
      [{ 'sailing_code' => 'IJKL', 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
         'departure_date' => '2022-01-31', 'arrival_date' => '2022-02-28' }],
      [
        { 'sailing_code' => 'MNOP', 'origin_port' => 'CNSHA', 'destination_port' => 'SGSIN',
          'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01' },
        { 'sailing_code' => 'QRST', 'origin_port' => 'SGSIN', 'destination_port' => 'NLRTM',
          'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02' }
      ],
      [
        { 'sailing_code' => 'UVWX', 'origin_port' => 'CNSHA', 'destination_port' => 'SGSIN',
          'departure_date' => '2022-01-31', 'arrival_date' => '2022-02-28' },
        { 'sailing_code' => 'YZAB', 'origin_port' => 'SGSIN', 'destination_port' => 'NLRTM',
          'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01' }
      ]
    ]
  end
  let(:converted_rates) do
    [
      { 'sailing_code' => 'ABCD', 'rate' => '1000.01' },
      { 'sailing_code' => 'EFGH', 'rate' => '1000.10' },
      { 'sailing_code' => 'IJKL', 'rate' => '3000.01' },
      { 'sailing_code' => 'MNOP', 'rate' => '3000.10' },
      { 'sailing_code' => 'QRST', 'rate' => '5000.01' },
      { 'sailing_code' => 'UVWX', 'rate' => '6000.01' },
      { 'sailing_code' => 'YZAB', 'rate' => '7000.01' }
    ]
  end
  let(:rates) do
    [
      {
        'sailing_code' => 'ABCD',
        'rate' => '777.77',
        'rate_currency' => 'USD'
      },
      {
        'sailing_code' => 'EFGH',
        'rate' => '890.32',
        'rate_currency' => 'EUR'
      },
      {
        'sailing_code' => 'IJKL',
        'rate' => '97453',
        'rate_currency' => 'JPY'
      },
      {
        'sailing_code' => 'MNOP',
        'rate' => '456.78',
        'rate_currency' => 'USD'
      },
      {
        'sailing_code' => 'QRST',
        'rate' => '761.96',
        'rate_currency' => 'EUR'
      },
      {
        'sailing_code' => 'ERXQ',
        'rate' => '261.96',
        'rate_currency' => 'EUR'
      },
      {
        'sailing_code' => 'ETRF',
        'rate' => '70.96',
        'rate_currency' => 'USD'
      },
      {
        'sailing_code' => 'ETRG',
        'rate' => '69.96',
        'rate_currency' => 'USD'
      },
      {
        'sailing_code' => 'ETRB',
        'rate' => '439.96',
        'rate_currency' => 'USD'
      }
    ]
  end
  let(:exchange_rates) do
    {
      "2022-01-29": {
        "usd": 1.1138,
        "jpy": 130.85
      },
      "2022-01-30": {
        "usd": 1.1138,
        "jpy": 132.97
      },
      "2022-01-31": {
        "usd": 1.1156,
        "jpy": 131.2
      },
      "2022-02-01": {
        "usd": 1.126,
        "jpy": 130.15
      },
      "2022-02-02": {
        "usd": 1.1323,
        "jpy": 133.91
      },
      "2022-02-15": {
        "usd": 1.1483,
        "jpy": 149.93
      },
      "2022-02-16": {
        "usd": 1.1482,
        "jpy": 149.93
      }
    }
  end

  before do
    allow(Sailings::RouteFinder).to receive(:call).and_return(Success(routes))
    allow(Sailings::CurrencyConverter).to receive(:call).and_return(Success(converted_rates))
    allow(MapReduceClient).to receive(:call).and_return(Success(sailings: [], rates:, exchange_rates:))
  end

  describe '#call' do
    subject { described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', strategy:) }
    context 'when route exists' do
      context 'when strategy is cheapest' do
        let(:strategy) { 'cheapest' }

        context 'when there are multiple routes' do
          let(:converted_rates) do
            [
              { 'sailing_code' => 'ABCD', 'rate' => '1000.01' },
              { 'sailing_code' => 'EFGH', 'rate' => '999.01' },
              { 'sailing_code' => 'IJKL', 'rate' => '999.01' },
              { 'sailing_code' => 'MNOP', 'rate' => '3000.10' },
              { 'sailing_code' => 'QRST', 'rate' => '5000.01' }
            ]
          end

          it 'returns the first cheapest sailing' do
            expect(subject).to be_success
            expect(subject.value!).to eq([{ 'sailing_code' => 'EFGH',
                                            'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                                            'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02',
                                            'rate' => '890.32',
                                            'rate_currency' => 'EUR' }])
          end
        end
        context 'when there is only one route' do
          let(:converted_rates) do
            [
              { 'sailing_code' => 'ABCD', 'rate' => '1000.01' },
              { 'sailing_code' => 'EFGH', 'rate' => '999.01' },
              { 'sailing_code' => 'IJKL', 'rate' => '70.01' },
              { 'sailing_code' => 'MNOP', 'rate' => '3000.10' },
              { 'sailing_code' => 'QRST', 'rate' => '1.01' }
            ]
          end
          it 'returns the cheapest sailing' do
            expect(subject).to be_success
            expect(subject.value!).to eq([{ 'sailing_code' => 'IJKL',
                                            'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                                            'departure_date' => '2022-01-31', 'arrival_date' => '2022-02-28',
                                            'rate' => '97453',
                                            'rate_currency' => 'JPY' }])
          end
        end
      end

      context 'when strategy is fastest' do
        let(:strategy) { 'fastest' }

        context 'when there are multiple routes' do
          let(:routes) do
            [
              [{ 'sailing_code' => 'ABCD', 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                 'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01' }],
              [{ 'sailing_code' => 'EFGH', 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                 'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02' }]
            ]
          end

          it 'returns the first sailing' do
            expect(subject).to be_success
            expect(subject.value!).to eq([{ 'sailing_code' => 'ABCD',
                                            'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                                            'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01',
                                            'rate' => '777.77', 'rate_currency' => 'USD' }])
          end
        end

        context 'when there is only one route' do
          it 'returns the fastest sailing' do
            expect(subject).to be_success
            expect(subject.value!).to eq([{ 'sailing_code' => 'ABCD',
                                            'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
                                            'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01',
                                            'rate' => '777.77', 'rate_currency' => 'USD' }])
          end
        end
      end

      context 'when strategy is not specified' do
        let(:strategy) { nil }

        it 'returns all sailings' do
          expect(subject).to be_success
          expect(subject.value!.map { |m| m['sailing_code'] }).to eq(%w[ABCD EFGH IJKL MNOP QRST UVWX YZAB])
        end
      end
    end

    context 'when route does not exist' do
      let(:strategy) { nil }
      let(:routes) { [] }
      it 'returns an error' do
        expect(subject).to be_failure
        expect(subject.failure).to eq('No sailings found')
      end
    end
  end
end
