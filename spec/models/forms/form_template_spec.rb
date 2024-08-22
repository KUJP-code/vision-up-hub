# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplate do
  it 'has a valid factory' do
    expect(build(:form_template)).to be_valid
  end

  context 'when adding fields' do
    it 'can add text fields' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_text_field)])
      expect(template.fields.first.class).to eq(FormTemplateTextField)
    end

    it 'can add text areas' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_text_area)])
      expect(template.fields.first.class).to eq(FormTemplateTextArea)
    end

    it 'can add check boxes' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_check_box)])
      expect(template.fields.first.class).to eq(FormTemplateCheckBox)
    end
  end

  it 'shows validation errors for fields' do
    template = build(:form_template,
                     fields: [attributes_for(:form_template_text_field, name: nil)])
    template.valid?
    expect(template.errors.full_messages).to include('Fields [0] Name を入力してください')
  end
end
