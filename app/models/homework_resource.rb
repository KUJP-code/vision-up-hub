# frozen_string_literal: true

class HomeworkResource < ApplicationRecord
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
  belongs_to :english_class
  belongs_to :course

  validates :week, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }

  def date_for(org)
    plan = org.plans.find_by(course_id:)
    return unless plan

    plan.start + (week - 1).weeks
  end
end
