# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormSubmission do
  it 'has a valid factory' do
    expect(build(:form_submission)).to be_valid
  end

  it 'gets its fields from the template' do
    template = create(:form_template, fields: [attributes_for(:form_template_single_input)])
    submission = create(:form_submission, form_template: template)
    expect(submission.fields).to eq(template.fields)
  end
end
