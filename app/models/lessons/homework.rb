# frozen_string_literal: true

class Homework < ApplicationRecord
  belong_to :course
  has_one_attached :questions
  has_one_attached :answers

  validates :week, presence: true, numericality: { only_integer: true }, inclusion: { in: 1..52 }
end
