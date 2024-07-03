# frozen_string_literal: true

module Gradeable
  extend ActiveSupport::Concern

  SCHOOL_AGE_MAP = {
    3 => '年少',
    4 => '年中',
    5 => '年長',
    6 => '小学１年生',
    7 => '小学２年生',
    8 => '小学３年生',
    9 => '小学４年生',
    10 => '小学５年生',
    11 => '小学６年生',
    12 => '中学１年生',
    13 => '中学２年生',
    14 => '中学３年生',
    15 => '高校生以上'
  }.freeze

  included do
    def grade
      return '' if birthday.nil?

      school_age = Time.zone.today.year - birthday.year
      school_age -= 1 if born_after_school_start?
      school_age -= 1 if before_new_school_year?
      return "#{calendar_age}歳" if school_age < 3

      SCHOOL_AGE_MAP[school_age] || ''
    end
  end

  def before_birthday?
    current_month = Time.zone.today.month
    current_month < birthday.month ||
      (current_month == birthday.month &&
        Time.zone.today.day < birthday.day)
  end

  def before_new_school_year?
    current_month = Time.zone.today.month
    current_month < 4 ||
      (current_month == 4 && Time.zone.today.day < 1)
  end

  def born_after_school_start?
    (birthday.month > 3 && birthday.day > 1) ||
      birthday.month > 4
  end

  def calendar_age
    age = Time.zone.today.year - birthday.year
    age -= 1 if before_birthday?
    age
  end
end
