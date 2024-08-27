# frozen_string_literal: true

class FormTemplate < ApplicationRecord
  include StoreModel::NestedAttributes

  FormTemplateField = StoreModel.one_of do |json|
    input_type = json[:input_type] || json['input_type']
    FormTemplateSingleInput if FormTemplateSingleInput::INPUT_TYPES.include?(input_type)
    # FormTemplateMultiInput if FormTemplateMultiInput::INPUT_TYPES.include?(input_type)
  end

  attribute :fields, FormTemplateField.to_array_type
  accepts_nested_attributes_for :fields, allow_destroy: true,
                                         reject_if: :all_blank
  validates :fields, store_model: { merge_array_errors: true }

  belongs_to :organisation
  has_many :form_submissions, dependent: :restrict_with_error
end
