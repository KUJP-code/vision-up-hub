# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestResult do
  subject(:test_result) { build(:test_result, test:, new_level: 'sky_three') }

  let(:test) { create(:test, thresholds: "Sky Three:80\nSky Two:70\nSky One:60") }

  it 'has a valid factory' do
    expect(test_result).to be_valid
  end

  it 'converts string values for answers to integers' do
    test_result.answers = { 'Reading' => %w[1 2 3 4] }
    test_result.save
    expect(test_result.answers).to eq({ 'Reading' => [1, 2, 3, 4] })
  end

  context 'when auto-updating student level' do
    let(:student) { create(:student, level: :sky_one) }

    it 'updates student level with new level when saved' do
      test_result.student = student
      test_result.save!
      expect(student.reload.level).to eq('sky_three')
    end

    it 'updates student level to Galaxy 2 if they would join evening course' do
      test.update(thresholds: 'Specialist:10')
      test_result.student = student
      test_result.new_level = 'specialist'
      test_result.save!
      expect(student.reload.level).to eq('galaxy_two')
    end
  end

  context "when saving student's current grade" do
    let(:student) { create(:student) }

    it 'sets grade col as student grade' do
      test_result.student = student
      test_result.save!
      expect(test_result.grade).to eq(student.grade)
    end

    it 'does not reset grade when updated' do
      original_grade = student.grade
      test_result.student = student
      test_result.save!
      student.update(birthday: Time.zone.today)
      test_result.update!(answers: { 'Reading' => %w[1 2 3 4] })
      expect(test_result.grade).to eq(original_grade)
    end
  end

  context 'when dealing with recommended level' do
    it 'increases recommended level with high total percent' do
      test_result.total_percent = 100
      expect(test_result.recommended_level).to eq('sky_three')
    end

    it 'retains prev level with low total percent' do
      test_result.prev_level = :sky_one
      test_result.total_percent = 0
      expect(test_result.recommended_level).to eq('sky_one')
    end

    it 'prevents save without reason if new_level is diff from recommended' do
      result = build(:test_result, test:, prev_level: :sky_one,
                                   total_percent: 79, reason: '')
      expect(result).not_to be_valid
    end

    it 'provides helpful error message if required reason not provided' do
      result = build(:test_result, test:, prev_level: :sky_one,
                                   total_percent: 79, reason: '')
      result.valid?
      expect(result.errors.full_messages)
        .to include("Reason #{I18n.t('test_results.errors.reason_required')}")
    end

    it 'allows results with new level diff from recommended if reason provided' do
      result = create(:test_result, test:, prev_level: :sky_one,
                                    total_percent: 79, reason: 'too close')
      expect(result).to be_valid
    end
  end
end
