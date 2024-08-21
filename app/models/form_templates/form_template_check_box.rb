# frozen_string_literal: true

class FormTemplateCheckBox
  include StoreModel::Model

  attribute :input_type, :string, default: 'check_box'
  attribute :name, :string
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes

  validates :name, presence: true

  def form_helper
    input_type.to_sym
  end
end
