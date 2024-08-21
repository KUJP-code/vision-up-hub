# frozen_string_literal: true

class FieldAttributes
  include StoreModel::Model

  attribute :placeholder, :string
  attribute :required, :boolean, default: false
end
