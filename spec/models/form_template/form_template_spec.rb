# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplate do
  it 'has a valid factory' do
    expect(build(:form_template)).to be_valid
  end

  it 'can add fields' do
    template = create(:form_template,
                      fields:
                        [attributes_for(:form_template_text_field)
                          .merge('input_type' => 'text_field')])
    expect(template.fields.first.class).to eq(FormTemplateTextField)
  end

  it 'shows validation errors for fields' do
  end
end
