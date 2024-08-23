# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateTextArea do
  it 'has a valid factory' do
    expect(build(:form_template_text_area)).to be_valid
  end

  it 'responds to #form_helper with :text_area_tag' do
    expect(build(:form_template_text_area).form_helper).to eq(:text_area_tag)
  end

  it_behaves_like 'input attributable'
end
