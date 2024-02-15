# frozen_string_literal: true

class ProposedChange < ApplicationRecord
  include Linkable, Listable

  LISTABLE_ATTRIBUTES = %i[
    add_difficulty
    example_sentences
    extra_fun
    instructions
    intro
    large_groups
    materials
    notes
    outro
  ].freeze

  belongs_to :proponent, class_name: 'User'
  belongs_to :lesson

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  def proposals
    attributes
      .compact_blank
      .except('id', 'created_at', 'lesson_id', 'proponent_id', 'status', 'updated_at')
  end
end
