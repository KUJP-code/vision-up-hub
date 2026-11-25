# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportCardBatchService do
  subject(:students) { service.send(:fetch_students) }

  let(:service) { described_class.new(batch) }
  let(:school) { create(:school) }
  let(:sky_test) { create(:test, level: :sky_one) }
  let(:galaxy_test) { create(:test, level: :galaxy_one, thresholds: "Galaxy One:60\nGalaxy Two:70") }
  let!(:promoted) { create(:student, school:, organisation: school.organisation, level: 'sky_three') }
  let!(:galaxy_student) { create(:student, school:, organisation: school.organisation, level: 'galaxy_one',
                                          student_id: '2234567890') }

  before do
    # Saving the result promotes the student to Galaxy immediately
    create(:test_result, student: promoted, test: sky_test, prev_level: :sky_three, new_level: :galaxy_one,
                         reason: 'Moving up in December')
    create(:test_result, student: galaxy_student, test: galaxy_test, prev_level: :galaxy_one,
                         new_level: :galaxy_one, reason: 'Staying')
  end

  context 'with the Sky sheet' do
    let(:batch) { create(:report_card_batch, school:, level: 'sky') }

    it 'includes students who sat the test in Sky and have since moved up' do
      expect(promoted.reload.level).to eq('galaxy_one')
      expect(students).to contain_exactly(promoted)
    end

    it 'prints their card as a Sky card' do
      html = ApplicationController.render(
        template: 'report_card_batches/batch_print_version',
        layout: false,
        assigns: { reports: students.map { |s| StudentReportPdf.new(s, result: service.send(:report_result, s)) } }
      )

      expect(html).to include('Sky Three')
      expect(html).not_to include('Galaxy One')
    end
  end

  context 'with the Galaxy sheet' do
    let(:batch) { create(:report_card_batch, school:, level: 'galaxy') }

    it 'includes Galaxy students but not the ones who only just moved up' do
      expect(students).to contain_exactly(galaxy_student)
    end
  end

  context 'when the test level does not match the class the student sat it in' do
    let(:galaxy_test) { create(:test, level: :sky_one) }
    let(:batch) { create(:report_card_batch, school:, level: 'galaxy') }

    it 'goes by the level the student was in' do
      expect(students).to contain_exactly(galaxy_student)
    end
  end

  context 'when the test is for all levels' do
    let(:sky_test) { create(:test, level: :all_levels) }
    let(:batch) { create(:report_card_batch, school:, level: 'sky') }

    it 'uses the level they were in when tested' do
      expect(students).to contain_exactly(promoted)
    end
  end

  context 'when no one sat a test at that level' do
    let(:batch) { create(:report_card_batch, school:, level: 'land') }

    it 'renders a placeholder page that does not wait for charts' do
      html = ApplicationController.render(template: 'report_card_batches/batch_print_version',
                                          layout: false, assigns: { reports: [] })

      expect(students).to be_empty
      expect(html).to include('window.chartReady = true')
    end
  end
end
