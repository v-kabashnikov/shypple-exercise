# frozen_string_literal: true

class SailingSearchContract < Dry::Validation::Contract
  params do
    required(:strategy).filled(:string, included_in?: %w[cheapest fastest])
    required(:origin_port).filled(:string)
    required(:destination_port).filled(:string)
    optional(:max_legs).maybe(:integer)
  end
end
