# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course do
  it 'has a valid factory' do
    course = build(:course)
    expect(course).to be_valid
  end

  it 'creates kebab-case root path from name before validation' do
    course = create(:course, name: 'Test Course')
    expect(course.root_path).to eq('/test-course')
  end
end
