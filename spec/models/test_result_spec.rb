# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestResult do
  it 'has a valid factory' do
    expect(build(:test_result)).to be_valid
  end

  it 'updates student level with new level when saved' do
    student = create(:student, level: :land_one)
    create(:test_result, student:, new_level: :land_three)
    expect(student.reload.level).to eq('land_three')
  end
end
