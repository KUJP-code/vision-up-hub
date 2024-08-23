# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplateCheckBox do
  it 'has a valid factory' do
    expect(build(:form_template_check_box)).to be_valid
  end

  it 'responds to #form_helper with :check_box_tag' do
    expect(build(:form_template_check_box).form_helper).to eq(:check_box_tag)
  end
end
