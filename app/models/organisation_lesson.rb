# frozen_string_literal: true

class OrganisationLesson < ApplicationRecord
  belongs_to :organisation
  belongs_to :lesson

  validates :event_date, presence: true
end