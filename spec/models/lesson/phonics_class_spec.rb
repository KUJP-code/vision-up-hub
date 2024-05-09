# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhonicsClass do
  let(:phonics_class) { create(:phonics_class) }

  it 'has a valid factory' do
    expect(build(:phonics_class)).to be_valid
  end

  it_behaves_like 'lesson'

  context 'when generating PDF guide' do
    it 'contains title' do
      pdf = phonics_class.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings).to include('Test Phonics Class')
    end
  end
end
