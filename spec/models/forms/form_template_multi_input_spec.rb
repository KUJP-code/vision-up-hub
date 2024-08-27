# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateMultiInput do
  FormTemplateMultiInput::INPUT_TYPES.each do |input_type|
    it "has a valid factory for #{input_type}" do
      expect(build(:form_template_multi_input, input_type.to_sym)).to be_valid
    end
  end

  it 'responds to #form_helper with :input_type_tag' do
    field = build(:form_template_multi_input, :select)
    expect(field.form_helper).to eq(:select_tag)
  end

  it_behaves_like 'input attributable'

  # Input string should be in the form "option1:label1,option2:label2"
  # Spaces are allowed, they'll be stripped
  it 'builds an array of options for selection from input string' do
    collection_string = 'option1:label1,option2:label2'
    field = build(:form_template_multi_input, :select, options: collection_string)
    expect(field.options).to eq([%w[option1 label1], %w[option2 label2]])
  end
end
