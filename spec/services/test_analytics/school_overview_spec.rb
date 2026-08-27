# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestAnalytics::SchoolOverview do
  it 'aggregates recent school results without loading detailed reports' do
    organisation = create(:organisation)
    school = create(:school, organisation:, name: '川口')
    student = create(:student, organisation:, school:)
    create(:test_result, student:, total_percent: 76, reason: 'Seeded result')

    overview = described_class.new(TestResult.where(organisation:))

    expect(overview.period).to eq('Last 3 months')
    expect(overview.chart_data[:labels]).to eq(['Kawaguchi — 1 result'])
    expect(overview.chart_data[:datasets].first[:data]).to eq([76.0])
    expect(overview.chart_data[:datasets].second[:label]).to eq('All-school average · 76.0%')
  end
end
