# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sailings', type: :request do
  describe 'GET /search' do
    context 'with valid params' do
      let(:valid_params) do
        {
          strategy: 'cheapest',
          origin_port: 'HKG',
          destination_port: 'SIN'
        }
      end

      it 'returns a successful response' do
        get '/api/v1/sailings/', params: valid_params

        expect(response).to have_http_status(:success)
      end

      it 'invokes the Sailings::Search service' do
        expect(Sailings::Search).to receive(:call).with(valid_params).and_call_original

        get '/api/v1/sailings/', params: valid_params
      end
    end

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
  end
end
