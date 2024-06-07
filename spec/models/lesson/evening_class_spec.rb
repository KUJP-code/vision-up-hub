# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EveningClass do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:evening_class)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:evening_class).attach_guide
      expect(pdf).to be_nil
    end
  end
end
