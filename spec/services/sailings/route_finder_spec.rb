# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sailings::RouteFinder, type: :service do
  let(:sailings) do
    [
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-01',
        'arrival_date' => '2022-03-01',
        'sailing_code' => 'ABCD'
      },
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-02',
        'arrival_date' => '2022-03-02',
        'sailing_code' => 'EFGH'
      },
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-31',
        'arrival_date' => '2022-02-28',
        'sailing_code' => 'IJKL'
      },
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-30',
        'arrival_date' => '2022-03-05',
        'sailing_code' => 'MNOP'
      },
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-29',
        'arrival_date' => '2022-02-15',
        'sailing_code' => 'QRST'
      },
      {
        'origin_port' => 'CNSHA',
        'destination_port' => 'ESBCN',
        'departure_date' => '2022-01-29',
        'arrival_date' => '2022-02-12',
        'sailing_code' => 'ERXQ'
      },
      {
        'origin_port' => 'ESBCN',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-15',
        'arrival_date' => '2022-03-29',
        'sailing_code' => 'ETRF'
      },
      {
        'origin_port' => 'ESBCN',
        'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-16',
        'arrival_date' => '2022-02-20',
        'sailing_code' => 'ETRG'
      },
      {
        'origin_port' => 'ESBCN',
        'destination_port' => 'BRSSZ',
        'departure_date' => '2022-02-16',
        'arrival_date' => '2022-03-14',
        'sailing_code' => 'ETRB'
      }
    ]
  end
  let(:direct_routes) do
    [[{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01',
        'sailing_code' => 'ABCD' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02',
        'sailing_code' => 'EFGH' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-31', 'arrival_date' => '2022-02-28',
        'sailing_code' => 'IJKL' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-30', 'arrival_date' => '2022-03-05',
        'sailing_code' => 'MNOP' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-15',
        'sailing_code' => 'QRST' }]]
  end
  let(:all_routes) do
    [[{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-01', 'arrival_date' => '2022-03-01',
        'sailing_code' => 'ABCD' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-02', 'arrival_date' => '2022-03-02',
        'sailing_code' => 'EFGH' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-31', 'arrival_date' => '2022-02-28',
        'sailing_code' => 'IJKL' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-30', 'arrival_date' => '2022-03-05',
        'sailing_code' => 'MNOP' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-15',
        'sailing_code' => 'QRST' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'ESBCN',
        'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-12',
        'sailing_code' => 'ERXQ' },
      { 'origin_port' => 'ESBCN', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-15', 'arrival_date' => '2022-03-29',
        'sailing_code' => 'ETRF' }],
     [{ 'origin_port' => 'CNSHA', 'destination_port' => 'ESBCN',
        'departure_date' => '2022-01-29', 'arrival_date' => '2022-02-12',
        'sailing_code' => 'ERXQ' },
      { 'origin_port' => 'ESBCN', 'destination_port' => 'NLRTM',
        'departure_date' => '2022-02-16', 'arrival_date' => '2022-02-20',
        'sailing_code' => 'ETRG' }]]
  end
  let(:route_params) { { sailings:, origin_port: 'CNSHA', destination_port: 'NLRTM', max_legs: } }
  describe '#call' do
    subject do
      described_class.call(route_params)
    end

    context 'when routes exist' do
      context 'when max_legs is not specified' do
        let(:max_legs) { nil }

        it 'finds all possible routes' do
          expect(subject).to be_success
          expect(subject.value!).to match_array(all_routes)
        end
      end

      context 'when max_legs is 1' do
        let(:max_legs) { 1 }

        it 'finds only direct routes' do
          expect(subject).to be_success
          expect(subject.value!).to match_array(direct_routes)
        end
      end
    end

    context 'when no routes exist because of date mismatch' do
      let(:max_legs) { nil }
      let(:sailings) do
        [{
          'origin_port' => 'CNSHA',
          'destination_port' => 'ESBCN',
          'departure_date' => '2022-01-29',
          'arrival_date' => '2022-02-12',
          'sailing_code' => 'ERXQ'
        },
         {
           'origin_port' => 'ESBCN',
           'destination_port' => 'NLRTM',
           'departure_date' => '2022-02-11',
           'arrival_date' => '2022-03-11',
           'sailing_code' => 'ETRF'
         },
         {
           'origin_port' => 'ESBCN',
           'destination_port' => 'NLRTM',
           'departure_date' => '2022-02-09',
           'arrival_date' => '2022-02-20',
           'sailing_code' => 'ETRG'
         }]
      end

      it 'returns an empty array' do
        expect(subject).to be_success
        expect(subject.value!).to eq([])
      end
    end

    context 'when no routes exist because no such origin port' do
      let(:max_legs) { nil }
      let(:route_params) { { sailings:, origin_port: 'ILHFA', destination_port: 'NLRTM', max_legs: } }

      it 'returns an empty array' do
        expect(subject).to be_success
        expect(subject.value!).to eq([])
      end
    end

    context 'when no routes exist because no such destination port' do
      let(:max_legs) { nil }
      let(:route_params) { { sailings:, origin_port: 'CNSHA', destination_port: 'ILTLV', max_legs: } }

      it 'returns an empty array' do
        expect(subject).to be_success
        expect(subject.value!).to eq([])
      end
    end
  end
end
