# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateTextField do
  it 'has a valid factory' do
    expect(build(:form_template_text_field)).to be_valid
  end

  it_behaves_like 'input attributable'
end
