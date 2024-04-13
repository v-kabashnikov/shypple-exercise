# frozen_string_literal: true

module Api
  module V1
    class SailingsController < ActionController::API
      include ApiErrors
      include ApiValidations

      before_action :validate_params, only: :index

      def index
        render json: sailings, status: :ok
      end

      private

      def sailings
        Sailings::Search.call(**@valid_params)
      end

      def validate_params
        validation = SailingSearchContract.new.call(params.to_unsafe_h)
        result_validation(validation)
      end
    end
  end
end
