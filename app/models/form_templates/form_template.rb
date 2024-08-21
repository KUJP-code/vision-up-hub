# frozen_string_literal: true

class FormTemplate < ApplicationRecord
  FormTemplateField = StoreModel.one_of do |json|
    case json[:input_type]
    when 'text'
      FormTemplateTextField
    end
  end

  attribute :fields, FormTemplateField.to_array_type

  belongs_to :organisation
  has_many :form_submissions, dependent: :restrict_with_error
end
