# frozen_string_literal: true

class FormTemplateCheckBox
  include StoreModel::Model

  attr_reader :_destroy

  attribute :explanation, :string
  attribute :input_type, :string, default: 'check_box'
  attribute :name, :string
  attribute :position, :integer

  validates :name, :position, presence: true

  def form_helper
    :"#{input_type}_tag"
  end
end
