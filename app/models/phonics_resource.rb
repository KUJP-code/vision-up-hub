# frozen_string_literal: true

class PhonicsResource < ApplicationRecord
  belongs_to :blob, class_name: 'ActiveStorage::Blob'
  belongs_to :phonics_class

  validates :week, presence: true
end
