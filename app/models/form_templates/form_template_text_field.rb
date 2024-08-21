# frozen_string_literal: true

class FormTemplateTextField
  include StoreModel::Model

  attribute :name, :string
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes
end
