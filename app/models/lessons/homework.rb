# frozen_string_literal: true

class Homework < ApplicationRecord
  include Levelable

  belongs_to :course
  has_one_attached :questions
  has_one_attached :answers
  validates :level, presence: true
  validates :week, presence: true, numericality: { only_integer: true }, inclusion: { in: 1..52 }
  validates :week, uniqueness: { scope: %i[course_id level], message: 'already has homework for this level' }

end
