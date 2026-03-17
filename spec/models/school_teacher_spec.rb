# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolTeacher do
  it 'has a valid factory' do
    expect(build(:school_teacher)).to be_valid
  end

  it 'is invalid when the school belongs to a different organisation than the teacher' do
    teacher = create(:user, :teacher)
    other_school = create(:school)

    school_teacher = build(:school_teacher, teacher:, school: other_school)

    expect(school_teacher).not_to be_valid
    expect(school_teacher.errors[:school]).to include(
      'must belong to the same organisation as the teacher'
    )
  end
end
