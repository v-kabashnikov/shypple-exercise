module ApiErrors
  extend ActiveSupport::Concern

  included do
    rescue_from(StandardError, with: :handle_unexpected_exception)
  end

  private

  def handle_unexpected_exception(exception)
    render json: { error: exception.message }, status: :internal_server_error
  end

  def error_response(error_messages, status)
    render json: { error: error_messages }, status: status
  end
end
