# frozen_string_literal: true

class Exercise < Lesson
  include ExercisePdf, Listable

  alias_attribute :cardio_and_stretching, :intro
  alias_attribute :form_practice, :vocab
  alias_attribute :cooldown_and_recap, :outro
  store_accessor :lang_goals, :land, :sky, :galaxy, suffix: true

  has_one_attached :guide # TODO: remove this once guide is finalized

  has_one_attached :cardio_image
  has_one_attached :form_practice_image
  has_one_attached :activity_image
  has_one_attached :cooldown_image

  ATTRIBUTES = %i[
    goal resources subtype land_lang_goals sky_lang_goals
    galaxy_lang_goals materials goal warning cardio_and_stretching
    form_practice instructions cooldown_and_recap cardio_image
    form_practice_image activity_image cooldown_image guide
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    land_lang_goals sky_lang_goals galaxy_lang_goals materials
    cardio_and_stretching form_practice instructions cooldown_and_recap
  ].freeze

  enum level: { all_levels: 0, kindy: 1, elementary: 2 }

  enum subtype: {
    aerobics: 0,
    control: 1,
    jumping: 2,
    throwing: 3
  }
end
