# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sailings', type: :request do
  describe 'GET /search' do
    context 'with valid params' do
      let(:valid_params) do
        {
          search_type: 'direct',
          origin_port: 'HKG',
          destination_port: 'SIN'
        }
      end

      # it 'returns a successful response' do
      #   get '/api/v1/sailings/', params: valid_params

      #   expect(response).to have_http_status(:success)
      # end
    end
  end
end
