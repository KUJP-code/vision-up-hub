# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PearsonResult do
  describe 'associations' do
    it 'belongs to student' do
      r = build(:pearson_result)
      expect(r.student).to be_present
    end
  end

  describe 'validations' do
    it 'requires test_name and test_taken_at' do
      r = build(:pearson_result, test_name: nil, test_taken_at: nil)
      expect(r).not_to be_valid
      expect(r.errors[:test_name]).to be_present
      expect(r.errors[:test_taken_at]).to be_present
    end

    it 'enforces code inclusion ok/bl/ns' do
      r = build(:pearson_result, listening_code: 'wat')
      expect(r).not_to be_valid
      expect(r.errors[:listening_code]).to be_present
    end

    it 'allows integer scores or nil' do
      expect(build(:pearson_result, reading_score: nil)).to be_valid
      expect(build(:pearson_result, reading_score: 42)).to be_valid
      expect(build(:pearson_result, reading_score: 42.1)).not_to be_valid
    end
  end

  describe 'scopes' do
    let(:student) { create(:student) }

    it '.for_test filters by name' do
      r1 = create(:pearson_result, student:, test_name: 'Versant')
      _r2 = create(:pearson_result, student:, test_name: 'GSE')
      expect(PearsonResult.for_test('Versant')).to contain_exactly(r1)
    end

    it '.for_form filters when present' do
      r1 = create(:pearson_result, student:, form: 'Form 1')
      _r2 = create(:pearson_result, student:, form: 'Form 3')
      expect(PearsonResult.for_form('Form 1')).to contain_exactly(r1)
    end

    it '.recent orders by test_taken_at desc' do
      older = create(:pearson_result, student:, test_taken_at: 2.days.ago.change(sec: 0))
      newer = create(:pearson_result, student:, test_taken_at: 1.day.ago.change(sec: 0))
      expect(PearsonResult.recent.first).to eq(newer)
      expect(PearsonResult.recent.second).to eq(older)
    end

    it '.latest_per_test returns only the latest per (student_id, test_name)' do
      t0 = Time.zone.parse('2025-06-01 10:00')
      t1 = Time.zone.parse('2025-06-10 10:00')

      create(:pearson_result, student:, test_name: 'Versant', test_taken_at: t0)
      latest = create(:pearson_result, student:, test_name: 'Versant', test_taken_at: t1)
      # Different test_name should not be collapsed together:
      other = create(:pearson_result, student:, test_name: 'GSE', test_taken_at: t1)

      rows = PearsonResult.latest_per_test.where(student_id: student.id)
      expect(rows).to contain_exactly(latest, other)
    end
  end

  describe '#average_score' do
    it 'averages only present (OK) scores' do
      r = build(:pearson_result, listening_score: 50, reading_score: 52, writing_score: 48, speaking_score: 50)
      expect(r.average_score).to eq(50) # (50+52+48+50)/4 = 50
    end

    it 'excludes BL/NS (nil scores)' do
      r = build(:pearson_result, :bl_listening, reading_score: 52, writing_score: 48, speaking_score: 50)
      expect(r.average_score).to eq(50) # (52+48+50)/3 = 50
    end

    it 'returns nil when no OK scores exist' do
      r = build(:pearson_result,
                listening_score: nil, listening_code: 'bl',
                reading_score: nil,   reading_code: 'ns',
                writing_score: nil,   writing_code: 'ns',
                speaking_score: nil,  speaking_code: 'bl')
      expect(r.average_score).to be_nil
    end

    it 'respects precision' do
      r = build(:pearson_result, listening_score: 49, reading_score: 50, writing_score: 51, speaking_score: nil,
                                 speaking_code: 'ns')
      # (49+50+51) / 3 = 50.0
      expect(r.average_score(precision: 1)).to eq(50.0)
    end
  end

  describe 'unique index behavior' do
    it 'prevents duplicate sittings per student/test_name/form/test_taken_at' do
      student = create(:student)
      attrs = {
        student:,
        test_name: 'Versant',
        form: 'Form 3',
        test_taken_at: Time.zone.parse('2025-06-10 10:00')
      }
      create(:pearson_result, **attrs)
      dup = build(:pearson_result, **attrs)

      expect { dup.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end
