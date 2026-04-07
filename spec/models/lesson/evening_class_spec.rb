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

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:evening_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
