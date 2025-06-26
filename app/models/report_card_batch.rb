class ReportCardBatch < ApplicationRecord
  belongs_to :school
  belongs_to :user
  has_one_attached :file

  BATCH_LEVELS = %w[kindy land sky galaxy].freeze

  enum level: BATCH_LEVELS.index_with(&:to_s)
  enum status: { pending: 'pending', generating: 'generating', complete: 'complete', failed: 'failed' }, _suffix: true
  validates :level, inclusion: { in: BATCH_LEVELS }
end