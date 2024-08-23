# frozen_string_literal: true

class FormSubmission < ApplicationRecord
  belongs_to :form_template
  belongs_to :parent, class_name: 'User', optional: true
  belongs_to :organisation
  belongs_to :staff, class_name: 'User'

  delegate :fields, to: :form_template
end
