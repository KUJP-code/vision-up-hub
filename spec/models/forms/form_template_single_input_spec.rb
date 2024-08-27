# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateSingleInput do
  FormTemplateSingleInput::INPUT_TYPES.each do |input_type|
    it "has a valid factory for #{input_type}" do
      expect(build(:form_template_single_input, input_type.to_sym)).to be_valid
    end
  end

  it 'responds to #form_helper with :input_type_tag' do
    field = build(:form_template_single_input, :text_field)
    expect(field.form_helper).to eq(:text_field_tag)
  end

  it_behaves_like 'input attributable'

  it 'does not accept input attributes for check boxes' do
    field = build(:form_template_single_input, :check_box, input_attributes: { required: true })
    expect(field).not_to be_valid
  end
end
