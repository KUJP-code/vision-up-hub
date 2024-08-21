# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateTextArea do
  it 'has a valid factory' do
    expect(build(:form_template_text_area)).to be_valid
  end

  it 'responds to #form_helper with :text_area' do
    expect(build(:form_template_text_area).form_helper).to eq(:text_area)
  end

  it_behaves_like 'input attributable'
end
