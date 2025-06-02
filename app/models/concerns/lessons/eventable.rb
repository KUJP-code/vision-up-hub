# frozen_string_literal: true

module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :organisation_lessons, dependent: :destroy
    accepts_nested_attributes_for :organisation_lessons,
                                  reject_if: :all_blank,
                                  allow_destroy: true
  end

  class_methods do
    # Only rows that have an org-lesson for org_id
    def for_organisation(org_id)
      joins(:organisation_lessons)
        .where(organisation_lessons: { organisation_id: org_id })
    end

    # event_date on the join table is within the window
    def within_event_window(date, past: 1.month, future: 2.months)
      joins(:organisation_lessons)
        .where(organisation_lessons: {
                 event_date: (date - past)..(date + future)
               })
    end
  end
end
