# frozen_string_literal: true

module Proposable
  extend ActiveSupport::Concern
  NOT_PROPOSABLE =
    %w[admin_approval assigned_editor_id changed_lesson_id created_at
       creator_id curriculum_approval id released status type
       updated_at].freeze

  included do
    belongs_to :changed_lesson,
               class_name: 'Lesson',
               optional: true

    has_many :proposals, class_name: 'Lesson',
                         foreign_key: :changed_lesson_id,
                         inverse_of: :changed_lesson,
                         dependent: :nullify
    enum status: {
      proposed: 0,
      changes_needed: 1,
      rejected: 2,
      accepted: 3
    }

    def replace_with(proposal)
      proposal.attributes.each do |key, value|
        next if NOT_PROPOSABLE.include?(key)

        send(:"#{key}=", value)
      end

      save
    rescue StandardError
      false
    else
      proposal.destroy
      true
    end
  end
end
