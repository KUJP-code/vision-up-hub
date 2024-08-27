# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateSingleInput do
  it 'has a valid factory' do
    expect(build(:form_template_single_input)).to be_valid
  end

  it 'responds to #form_helper with :input_type_tag' do
    field = build(:form_template_single_input, :text_field)
    expect(field.form_helper).to eq(:text_field_tag)
  end

  it_behaves_like 'input attributable'
end
