# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sailings::Search, type: :service do
  let(:data) { JSON.parse(File.read('response.json')) }
  let(:sailings) { data['sailings'] }
  let(:rates) { data['rates'] }
  let(:exchange_rates) { data['exchange_rates'] }

  let(:params) do
    {
      origin_port: 'CNSHA',
      destination_port: 'NLRTM',
      strategy: 'cheapest',
      legs: '1'
    }
  end

  subject { described_class.new(params) }

  describe '#call' do
    context 'when parameters are valid' do
      it 'fetches data and performs search based on the strategy' do
        expect(subject.call).to be_truthy
        expect(subject.success?).to be true
      end

      it 'returns the cheapest direct sailing when strategy is cheapest and legs are 1' do
        cheapest_sailing = subject.call
        expect(cheapest_sailing['sailing_code']).to eq('MNOP')
      end

      it 'handles no strategy by returning all sailings between ports' do
        subject = described_class.new(origin_port: 'CNSHA', destination_port: 'NLRTM')
        all_sailings = subject.call
        expect(all_sailings.size).to eq(sailings.select do |s|
                                          s['origin_port'] == 'CNSHA' && s['destination_port'] == 'NLRTM'
                                        end.size)
      end
    end

    context 'when parameters are invalid' do
      let(:params) { { origin_port: nil, destination_port: 'NLRTM' } }

      it 'returns an error' do
        expect(subject.call).to eq(['Invalid search parameters'])
        # expect(subject.errors).not_to be_empty
        # expect(subject.errors.first).to eq('Invalid search parameters')
      end
    end
  end
end
