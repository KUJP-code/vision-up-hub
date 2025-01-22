# frozen_string_literal: true

class HomeworkResource < ApplicationRecord
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
  belongs_to :english_class
  belongs_to :course

  validates :week, presence: true
  validates :week, numericality: { only_integer: true }
  validates :week, comparison: { greater_than: 0, less_than: 53 }
end
