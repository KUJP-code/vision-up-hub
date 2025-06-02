# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganisationLesson do
  it 'has a valid factory' do
    expect(build(:organisation_lesson)).to be_valid
  end
end
