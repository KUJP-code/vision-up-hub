# frozen_string_literal: true

class InputAttributes
  include StoreModel::Model

  attribute :placeholder, :string
  attribute :required, :boolean, default: false
end
