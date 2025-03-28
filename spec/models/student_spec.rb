# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Student do
  include ActiveSupport::Testing::TimeHelpers

  it 'has a valid factory' do
    expect(build(:student)).to be_valid
  end

  it 'cannot have duplicate student IDs at same organisation' do
    organisation = create(:organisation)
    create(:student, student_id: '123', organisation:)
    duplicate = build(:student, student_id: '123', organisation:)
    expect(duplicate).not_to be_valid
  end

  it 'can have duplicate student IDs at different organisations' do
    create(:student, student_id: '123')
    duplicate = build(:student, student_id: '123', organisation: create(:organisation))
    expect(duplicate).to be_valid
  end

  it 'autogenerates student ID from DB organisation_id, school_id if not set' do
    school = create(:school)
    student = create(:student, school:, student_id: nil)
    expect(student.reload.student_id).to include("#{student.organisation_id}-#{school.id}-")
  end

  it 'autogenerates student ID from DB organisation_id, school_id if blank string' do
    school = create(:school)
    student = create(:student, school:, student_id: '')
    expect(student.reload.student_id).to include("#{student.organisation_id}-#{school.id}-")
  end

  it 'can reassign student ID that was autogenerated' do
    student = create(:student, student_id: nil)
    student.update(student_id: '123')
    expect(student.reload.student_id).to eq('123')
  end

  context 'when calculating school grade during 2023 school year' do
    before do
      travel_to Date.new(2024, 3, 14)
    end

    it 'gives real age when 1 year old' do
      student = build(:student, birthday: Date.new(2022, 4, 11))
      expect(student.grade).to eq('1歳')
    end

    it 'gives real age when 2 years old' do
      student = build(:student, birthday: Date.new(2021, 4, 11))
      expect(student.grade).to eq('2歳')
    end

    it 'is 3 years old when born 4/10/2020' do
      student = build(:student, birthday: Date.new(2020, 10, 4))
      expect(student.grade).to eq('3歳')
    end

    it 'is start of kindy when born before school start' do
      student = build(:student, birthday: Date.new(2020, 4, 1))
      expect(student.grade).to eq('年少')
    end

    it 'is 1st grade when born after school start' do
      student = build(:student, birthday: Date.new(2016, 4, 2))
      expect(student.grade).to eq('小学１年生')
    end

    it 'is 2nd grade when born before school start' do
      student = build(:student, birthday: Date.new(2016, 4, 1))
      expect(student.grade).to eq('小学２年生')
    end
  end

  context 'when calculating school grade during 2024 school year' do
    before do
      travel_to Date.new(2024, 4, 2)
    end

    it 'is start of kindy when born 4/10/2020' do
      student = build(:student, birthday: Date.new(2020, 10, 4))
      expect(student.grade).to eq('年少')
    end

    it 'is 2nd grade when born before school start' do
      student = build(:student, birthday: Date.new(2016, 4, 2))
      expect(student.grade).to eq('小学２年生')
    end

    it 'is 3rd grade when born after school start' do
      student = build(:student, birthday: Date.new(2016, 4, 1))
      expect(student.grade).to eq('小学３年生')
    end
  end

  context 'when calculating school grade during 2025 school year' do
    before do
      travel_to Date.new(2025, 4, 2)
    end

    it 'is middle of kindy when born 4/10/2020' do
      student = build(:student, birthday: Date.new(2020, 10, 4))
      expect(student.grade).to eq('年中')
    end

    it 'is 3rd grade when born after school start' do
      student = build(:student, birthday: Date.new(2016, 4, 2))
      expect(student.grade).to eq('小学３年生')
    end

    it 'is 4th grade when born before school start' do
      student = build(:student, birthday: Date.new(2016, 4, 1))
      expect(student.grade).to eq('小学４年生')
    end
  end
end
