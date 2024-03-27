# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Student do
  it 'has a valid factory' do
    expect(build(:student)).to be_valid
  end

  it 'cannot have duplicate student IDs at same school' do
    student = create(:student, student_id: '123')
    duplicate = build(:student, student_id: '123', school: student.school)
    expect(duplicate).not_to be_valid
  end

  it 'can have duplicate student IDs at different schools' do
    create(:student, student_id: '123')
    duplicate = build(:student, student_id: '123', school: create(:school))
    expect(duplicate).to be_valid
  end
end
