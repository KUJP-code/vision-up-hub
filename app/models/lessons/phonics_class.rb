# frozen_string_literal: true

class PhonicsClass < Lesson
  include Linkable, Listable, PdfImageValidatable, PhonicsClassPdf

  has_one_attached :pdf_image
  PDF_IMAGES = %i[pdf_image].freeze

  ATTRIBUTES = %i[
    add_difficulty
    extra_fun
    intro
    instructions
    links
    materials
    pdf_image
    productive_activity
    receptive_activity
    review
  ].freeze

  LISTABLE_ATTRIBUTES = %i[
    materials
    intro
    instructions
    receptive_activity
    productive_activity
    review
    add_difficulty
    extra_fun

  ].freeze

  validates :instructions, presence: true, unless: :galaxy?
  validates :receptive_activity, :productive_activity, presence: true, if: :galaxy?

  has_many :phonics_resources, dependent: :destroy
  accepts_nested_attributes_for :phonics_resources,
                                reject_if: :all_blank,
                                allow_destroy: true
  has_many :category_resources, through: :phonics_resources

  def listable_attributes
    if galaxy?
      %i[
        materials
        intro
        receptive_activity
        productive_activity
        review
        add_difficulty
        extra_fun
      ]
    else
      %i[
        materials
        intro
        instructions
        review
        add_difficulty
        extra_fun
      ]
    end
  end
end
