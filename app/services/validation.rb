# frozen_string_literal: true

module Validation
  include Dry::Monads[:result]

  def call(data = {})
    validate(data).then do |result|
      return Failure(result.errors.to_h) if result.failure?

      new(result.to_h).call
    end
  end

  private

  def parameters(&block)
    @parameters = block
  end

  def rules(&block)
    @rules = block
  end

  def validator
    local_parameters = @parameters
    local_rules      = @rules

    @validator ||= Class.new(::BaseContract) do
      params do
        instance_exec(&local_parameters)
      end

      instance_exec(&local_rules) if local_rules
    end.new
  end

  def validate(data)
    validator.call(data.to_h)
  end
end
