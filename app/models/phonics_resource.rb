# frozen_string_literal: true

class PhonicsResource < ApplicationRecord
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
  belongs_to :phonics_class
  belongs_to :course

  validates :course_id, presence: true
  validates :week, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }
end
