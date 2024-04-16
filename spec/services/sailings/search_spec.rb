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

  before do
    allow(Sailings::RouteFinder).to receive(:call).and_return(Success(routes))
    allow(Sailings::CurrencyConverter).to receive(:call).and_return(Success(converted_rates))
  end

  describe '#call' do
    subject { described_class.call(origin_port: 'CNSHA', destination_port: 'NLRTM', strategy:) }

    context 'when strategy is cheapest' do
      let(:strategy) { 'cheapest' }

      it 'applies the cheapest strategy correctly' do
        expect(subject).to be_success
        expect(subject.value!).to eq(routes.first)
      end
    end

    context 'when strategy is fastest' do
      let(:strategy) { 'fastest' }

      it 'applies the fastest strategy correctly' do
        expect(subject).to be_success
        expect(subject.value!).to eq(routes.first)
      end
    end

    context 'when strategy is not specified' do
      let(:strategy) { nil }

      it 'returns all sailings' do
        expect(subject).to be_success
        expect(subject.value!).to eq(routes)
      end
    end
  end
end
