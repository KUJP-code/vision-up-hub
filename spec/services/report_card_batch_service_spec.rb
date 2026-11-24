# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportCardBatchService do
  subject(:students) { described_class.new(batch).send(:fetch_students) }

  let(:school) { create(:school) }
  let(:sky_test) { create(:test, level: :sky_one) }
  let!(:promoted) { create(:student, school:, organisation: school.organisation, level: 'sky_three') }

  before do
    # Saving the result promotes the student to Galaxy immediately
    create(:test_result, student: promoted, test: sky_test, prev_level: :sky_three, new_level: :galaxy_one,
                         reason: 'Moving up in December')
  end

  context 'with the sheet for the level of the test taken' do
    let(:batch) { create(:report_card_batch, school:, level: 'sky') }

    it 'includes students who have since moved up' do
      expect(promoted.reload.level).to eq('galaxy_one')
      expect(students).to contain_exactly(promoted)
    end
  end

  context 'with the sheet for the level they moved up to' do
    let(:batch) { create(:report_card_batch, school:, level: 'galaxy') }

    it 'leaves them out' do
      expect(students).to be_empty
    end
  end

  context 'when the test is for all levels' do
    let(:sky_test) { create(:test, level: :all_levels) }
    let(:batch) { create(:report_card_batch, school:, level: 'sky') }

    it 'falls back to the level they were in when tested' do
      expect(students).to contain_exactly(promoted)
    end
  end
end
