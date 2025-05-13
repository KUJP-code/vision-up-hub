# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homework do
  subject(:homework) { build(:homework) }

  it 'has a valid factory' do
    expect(homework).to be_valid
  end

  it 'requires a course' do
    homework.course = nil
    expect(homework).not_to be_valid
  end

  it 'requires a level' do
    homework.level = nil
    expect(homework).not_to be_valid
  end

  it 'requires a week' do
    homework.week = nil
    expect(homework).not_to be_valid
  end

  it 'validates week is within 1 to 52' do
    homework.week = 0
    expect(homework).not_to be_valid

    homework.week = 53
    expect(homework).not_to be_valid
  end

  it 'validates uniqueness of week scoped to course and level' do
    create(:homework, course: homework.course, week: homework.week, level: homework.level)
    duplicate = build(:homework, course: homework.course, week: homework.week, level: homework.level)
    expect(duplicate).not_to be_valid
  end
end
