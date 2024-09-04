# frozen_string_literal: true

class Course < ApplicationRecord
  validates :title, :description, presence: true

  has_many :course_lessons, dependent: :destroy
  has_many :lessons, through: :course_lessons

  has_many :course_resources, dependent: :destroy
  has_many :category_resources, -> { distinct }, through: :course_resources

  has_many :course_tests, dependent: :destroy
  has_many :tests, through: :course_tests

  has_many :plans, -> { includes(:organisation) },
           dependent: :destroy, inverse_of: :course
  has_many :organisations, through: :plans

  def plan_date_data(org_id = nil)
    if org_id
      plans.select { |p| p.organisation_id == org_id }
           .to_h { |p| [p.organisation.name, { startDate: p.start }] }
    else
      plans.to_h { |p| [p.organisation.name, { startDate: p.start }] }
    end
  end
end
