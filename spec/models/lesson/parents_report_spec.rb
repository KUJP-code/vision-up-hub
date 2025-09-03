# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParentsReport do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:special_lesson)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:special_lesson).attach_guide
      expect(pdf).to be_nil
    end
  end
end
