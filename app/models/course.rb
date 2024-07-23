# frozen_string_literal: true

class Course < ApplicationRecord
  validates :title, presence: true

  has_many :course_lessons, dependent: :destroy
  accepts_nested_attributes_for :course_lessons,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :lessons, through: :course_lessons

  has_many :course_resources, dependent: :destroy
  accepts_nested_attributes_for :course_resources,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :category_resources, through: :course_resources

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
