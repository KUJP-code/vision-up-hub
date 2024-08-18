# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exercise do
  subject(:exercise) do
    create(:exercise,
           title: 'Test Exercise', subtype: :jumping,
           instructions: "Instruction 1\nInstruction 2" )
  end

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when generating PDF guide',
          skip: 'Temporarily disabled until finalised' do
    it 'contains title, subcategory and instructions' do
      pdf = exercise.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to include(
          'Test Exercise', 'Jumping', '1. Instruction 1', '2. Instruction 2'
        )
    end
  end
end
