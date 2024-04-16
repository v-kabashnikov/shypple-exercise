# frozen_string_literal: true

class BaseService
  extend Validation
  include Dry::Monads[:result]
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    raise NotImplementedError
  end
end
