# frozen_string_literal: true

module Api
  module V1
    class SailingsController < ActionController::API
      include ApiErrors
      include ApiValidations

      before_action :validate_params, only: :index

      def index
        raise NoSailings unless sailings

        render json: sailings, status: :ok
      end

      private

      def sailings
        @sailings ||= Sailings::Search.call(params[:origin_port], params[:destination_port], params[:search_type])
      end

      def validate_params
        validation = SailingSearchContract.new.call(params.to_unsafe_h)
        result_validation(validation)
      end
    end
  end
end
