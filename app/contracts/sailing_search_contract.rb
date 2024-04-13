# frozen_string_literal: true

class SailingSearchContract < Dry::Validation::Contract
  params do
    required(:search_type).filled(:string, included_in?: %w[direct indirect])
    required(:origin_port).filled(:string)
    required(:destination_port).filled(:string)
  end
end
