# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EveningClass do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:evening_class)).to be_valid
  end

  it 'requires a subtype' do
    lesson = build(:evening_class, subtype: nil)

    expect(lesson).not_to be_valid
    expect(lesson.errors[:subtype]).to include(I18n.t('errors.messages.blank'))
  end

  it 'restricts keep up lessons to keep up subtypes' do
    lesson = build(:evening_class, level: :keep_up_one, subtype: :literacy)

    expect(lesson).not_to be_valid
    expect(lesson.errors[:subtype]).to include('is not valid for this level')
  end

  it 'allows legacy specialist subtypes for compatibility' do
    lesson = build(:evening_class, level: :specialist, subtype: :literacy)

    expect(lesson).to be_valid
  end

  it 'stores purchase materials as a list for monthly materials reporting' do
    lesson = build(:evening_class, purchase_materials: "Paper\r\nGlue\n\nScissors")

    lesson.validate

    expect(lesson.purchase_materials).to eq(%w[Paper Glue Scissors])
  end

  it 'combines basic and purchase materials for guides' do
    lesson = build(
      :evening_class,
      basic_materials: "Pencils\nPaper",
      purchase_materials: "Glue\nScissors"
    )

    lesson.validate

    expect(lesson.materials).to eq(%w[Pencils Paper Glue Scissors])
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:evening_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
