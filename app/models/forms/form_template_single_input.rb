# frozen_string_literal: true

class FormTemplateSingleInput
  include StoreModel::Model

  INPUT_TYPES = %w[text_field text_area check_box].freeze

  attr_reader :_destroy

  attribute :explanation, :string
  attribute :input_type, :string
  attribute :input_attributes, InputAttributes.to_type
  accepts_nested_attributes_for :input_attributes,
                                allow_destroy: true, reject_if: :all_blank
  attribute :name, :string
  attribute :position, :integer

  validates :name, :position, presence: true
  validates :input_type, inclusion: { in: INPUT_TYPES }
  validate :no_attributes_if_checkbox

  def form_helper
    :"#{input_type}_tag"
  end

  private

  def no_attributes_if_checkbox
    return unless input_type == 'check_box'
    return if input_attributes.blank?

    errors.add(:input_attributes, 'cannot be set for a checkbox')
  end
end
