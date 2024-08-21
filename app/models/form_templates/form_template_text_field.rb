# frozen_string_literal: true

class FormTemplateTextField
  include StoreModel::Model

  attribute :name, :string
  attribute :field_attributes, FieldAttributes.to_type
end
