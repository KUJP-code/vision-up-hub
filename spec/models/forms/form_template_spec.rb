# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplate do
  it 'has a valid factory' do
    expect(build(:form_template)).to be_valid
  end

  context 'when adding single input fields' do
    it 'can add text fields' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_single_input, :text_field)])
      expect(template.fields.first.input_type).to eq('text_field')
    end

    it 'can add text areas' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_single_input, :text_area)])
      expect(template.fields.first.input_type).to eq('text_area')
    end

    it 'can add check boxes' do
      template = create(:form_template,
                        fields: [attributes_for(:form_template_single_input, :check_box)])
      expect(template.fields.first.input_type).to eq('check_box')
    end
  end

  it 'shows validation errors for fields' do
    template = build(:form_template,
                     fields: [attributes_for(:form_template_single_input, name: nil)])
    template.valid?
    expect(template.errors.full_messages).to include('Fields [0] Name を入力してください')
  end
end
