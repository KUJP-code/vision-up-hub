# frozen_string_literal: true

class FormTemplateTextArea
  include StoreModel::Model

  attribute :name, :string
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes

  def form_helper
    :text_area
  end
end
