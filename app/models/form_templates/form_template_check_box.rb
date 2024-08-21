# frozen_string_literal: true

class FormTemplateCheckBox
  include StoreModel::Model

  attribute :name, :string
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes

  def form_helper
    :check_box
  end
end
