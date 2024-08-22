# frozen_string_literal: true

class FormTemplateCheckBox
  include StoreModel::Model

  attr_reader :_destroy

  attribute :explanation, :string
  attribute :input_type, :string, default: 'check_box'
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes,
                                allow_destroy: true, reject_if: :all_blank
  attribute :name, :string
  attribute :position, :integer

  validates :name, :position, presence: true

  def form_helper
    input_type.to_sym
  end
end
