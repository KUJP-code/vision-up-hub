# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplate do
  it 'has a valid factory' do
    expect(build(:form_template)).to be_valid
  end

  context 'when adding single input fields' do
    FormTemplateSingleInput::INPUT_TYPES.each do |input_type|
      it 'can add text fields' do
        template = create(:form_template,
                          fields: [attributes_for(:form_template_single_input, input_type.to_sym)])
        expect(template.fields.first.input_type).to eq(input_type)
      end
    end
  end

  context 'when adding multi input fields' do
    FormTemplateMultiInput::INPUT_TYPES.each do |input_type|
      it 'can add text fields' do
        template = create(:form_template,
                          fields: [attributes_for(:form_template_multi_input, input_type.to_sym)])
        expect(template.fields.first.input_type).to eq(input_type)
      end
    end
  end

  it 'shows validation errors for fields' do
    template = build(:form_template,
                     fields: [attributes_for(:form_template_single_input, name: nil)])
    template.valid?
    expect(template.errors.full_messages).to include('Fields [0] Name を入力してください')
  end
end
