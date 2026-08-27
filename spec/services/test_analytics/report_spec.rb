# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestAnalytics::Report do
  it 'builds organisation comparison and progress metrics' do
    organisation = create(:organisation)
    school = create(:school, organisation:)
    student = create(:student, organisation:, school:)
    test = create(:test)
    result = create(:test_result, student:, test:, total_percent: 80,
                                  listen_percent: 70, read_percent: 80,
                                  write_percent: 90, reason: 'Teacher decision')

    report = described_class.new([result])

    expect(report.summary).to include(results: 1, students: 1, schools: 1, average: 80.0)
    expect(report.school_rows.first).to include(name: school.name, average: 80.0)
    expect(report.student_rows.first).to include(student: student.name, score: 80)
    expect(report.school_comparison_chart[:labels]).to eq(["#{school.name} — 1 result"])
    expect(report.school_comparison_chart[:datasets].second[:label]).to eq('All-school average · 80.0%')
    expect(report.school_chart_min).to eq(70)
  end
end
