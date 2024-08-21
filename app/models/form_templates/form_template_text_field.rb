# frozen_string_literal: true

class FormTemplateTextField
  include StoreModel::Model

  attribute :name, :string
  attribute :options, :json
end
