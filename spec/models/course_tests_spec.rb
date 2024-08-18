# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseTest do
  it 'has a valid factory' do
    expect(build(:course_test)).to be_valid
  end
end
