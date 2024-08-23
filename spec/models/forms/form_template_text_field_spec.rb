# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateTextField do
  it 'has a valid factory' do
    expect(build(:form_template_text_field)).to be_valid
  end

  it 'responds to #form_helper with :text_field_tag' do
    expect(build(:form_template_text_field).form_helper).to eq(:text_field_tag)
  end

  it_behaves_like 'input attributable'
end
