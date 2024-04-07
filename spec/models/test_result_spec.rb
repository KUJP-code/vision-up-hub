# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestResult do
  subject(:test_result) { build(:test_result, test:, total_percent: 100, new_level: 'sky_three') }

  let(:test) { create(:test, thresholds: 'Sky Three:80') }

  it 'has a valid factory' do
    expect(test_result).to be_valid
  end

  it 'updates student level with new level when saved' do
    student = create(:student, level: :sky_one)
    test_result.student = student
    test_result.save!
    expect(student.reload.level).to eq('sky_three')
  end

  context 'when dealing with recommended level' do
    it 'calculates the recommended level from total percent' do
      expect(test_result.recommended_level).to eq('sky_three')
    end

    it 'prevents save without reason if new_level is diff from recommended' do
      result = build(:test_result, test:, prev_level: :sky_one, total_percent: 79, reason: '')
      expect(result).not_to be_valid
    end

    it 'provides helpful error message if required reason not provided' do
      result = build(:test_result, test:, prev_level: :sky_one, total_percent: 79, reason: '')
      result.valid?
      expect(result.errors.full_messages)
        .to include("Reason #{I18n.t('test_results.errors.reason_required')}")
    end

    it 'allows results with new level diff from recommended if reason provided' do
      result = create(:test_result, test:, prev_level: :sky_one, total_percent: 79, reason: 'too close')
      expect(result).to be_valid
    end
  end
end
