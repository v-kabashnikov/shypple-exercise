# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sailings', type: :request do
  describe 'GET /search' do
    context 'with invalid params' do
      let(:invalid_params) do
        {
          strategy: 'wrong_strategy',
          origin_port: 'HKG',
          destination_port: 'SIN',
          max_legs: 'invalid'
        }
      end

      it 'returns a bad request response' do
        get '/api/v1/sailings/', params: invalid_params

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq('{"error":{"strategy":["must be one of: cheapest, fastest"],"max_legs":["must be an integer"]}}')
      end
    end

    context 'direct route' do
      let(:params) do
        {
          strategy: 'cheapest',
          origin_port: 'CNSHA',
          destination_port: 'NLRTM',
          max_legs: 1
        }
      end

      let(:expected_result) do
        [
          {
            "origin_port": 'CNSHA',
            "destination_port": 'NLRTM',
            "departure_date": '2022-01-30',
            "arrival_date": '2022-03-05',
            "sailing_code": 'MNOP',
            "rate": '456.78',
            "rate_currency": 'USD'
          }
        ]
      end

      it 'returns the cheapest sailing between origin port & destination port (PLS-0001)' do
        get('/api/v1/sailings/', params:)
        expect(response.body).to eq(expected_result.to_json)
      end
    end

    context 'cheapest direct or indirect' do
      let(:params) do
        {
          strategy: 'cheapest',
          origin_port: 'CNSHA',
          destination_port: 'NLRTM'
        }
      end

      let(:expected_result) do
        [
          {
            "origin_port": 'CNSHA',
            "destination_port": 'ESBCN',
            "departure_date": '2022-01-29',
            "arrival_date": '2022-02-12',
            "sailing_code": 'ERXQ',
            "rate": '261.96',
            "rate_currency": 'EUR'
          },
          {
            "origin_port": 'ESBCN',
            "destination_port": 'NLRTM',
            "departure_date": '2022-02-16',
            "arrival_date": '2022-02-20',
            "sailing_code": 'ETRG',
            "rate": '69.96',
            "rate_currency": 'USD'
          }
        ]
      end
      it 'returns route with two legs (WRT-0002)' do
        get('/api/v1/sailings/', params:)
        expect(response.body).to eq(expected_result.to_json)
      end
    end

    context 'fastest direct or indirect' do
      let(:params) do
        {
          strategy: 'fastest',
          origin_port: 'CNSHA',
          destination_port: 'NLRTM'
        }
      end

      let(:expected_result) do
        [
          {
            "origin_port": 'CNSHA',
            "destination_port": 'NLRTM',
            "departure_date": '2022-01-29',
            "arrival_date": '2022-02-15',
            "sailing_code": 'QRST',
            "rate": '761.96',
            "rate_currency": 'EUR'
          }
        ]
      end
      it 'returns route with one leg (TST-0003)' do
        get('/api/v1/sailings/', params:)
        expect(response.body).to eq(expected_result.to_json)
      end
    end
  end
end
