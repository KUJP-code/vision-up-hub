# frozen_string_literal: true

class FormSubmission < ApplicationRecord
  belongs_to :form_template
  belongs_to :parent, class_name: 'User'
  belongs_to :staff, class_name: 'User'
end
