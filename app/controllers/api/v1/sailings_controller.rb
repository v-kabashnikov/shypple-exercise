# frozen_string_literal: true

module Api
  module V1
    class SailingsController < ActionController::API
      include ApiErrors
      include ApiValidations

      before_action :validate_params, only: :index

      def index
        result = Sailings::Search.call(@valid_params)

        return render_error(result.failure, :bad_request) unless result.success?

        render json: result.value!, status: :ok
      end

      private

      def validate_params
        validation = SailingSearchContract.new.call(params.to_unsafe_h)
        result_validation(validation)
      end
    end
  end
end
