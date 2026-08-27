# frozen_string_literal: true

class TestAnalyticsController < ApplicationController
  before_action :authorize_analytics
  before_action :set_filters

  def index
    @report = TestAnalytics::Report.new(primary_results)
    @comparison_reports = comparison_windows.map do |label, start_date|
      [label, TestAnalytics::Report.new(results_since(start_date))]
    end
  end

  def export
    report = TestAnalytics::Report.new(primary_results)
    table = params[:table].presence_in(%w[schools students tests]) || 'students'
    send_data csv_for(report, table), filename: "test-analytics-#{table}-#{Date.current}.csv"
  end

  private

  def authorize_analytics
    authorize :test_analytics, "#{action_name}?"
  end

  def set_filters
    @organisations = Organisation.order(:name)
    @organisation = @organisations.find_by(id: params[:organisation_id]) || current_user.organisation
    @tests = Test.order(:name)
  end

  def base_results
    scope = TestResult.includes(:student, :test, school: :organisation)
                      .where(organisation_id: @organisation.id)
    scope = scope.where(test_id: params[:test_id]) if params[:test_id].present?
    scope
  end

  def primary_results
    recent = results_since(3.months.ago.to_date)
    if recent.exists?
      @reporting_period = 'Last 3 months'
      return recent.order(:tested_on)
    end

    latest_date = base_results.maximum(:tested_on)
    return base_results.none if latest_date.blank?

    @reporting_period = "Latest test set · #{latest_date.strftime('%B %Y')}"
    base_results.where(tested_on: latest_date.all_month).order(:tested_on)
  end

  def results_since(start_date)
    base_results.where(tested_on: start_date..Date.current)
  end

  def comparison_windows
    [
      ['Last 6 months', 6.months.ago.to_date],
      ['Last year', 1.year.ago.to_date],
      ['Last 5 years', 5.years.ago.to_date]
    ]
  end

  def csv_for(report, table)
    rows, headers = csv_rows(report, table)
    CSV.generate do |csv|
      csv << headers
      rows.each { |row| csv << headers.map { |header| row[header] } }
    end
  end

  def csv_rows(report, table)
    case table
    when 'schools'
      [report.school_rows, %i[name organisation students results average listening reading writing speaking improved_rate override_rate]]
    when 'tests'
      [report.test_rows, %i[name students results average listening reading writing speaking improved_rate override_rate]]
    else
      [report.student_rows, %i[date student student_id school test score change previous_level new_level]]
    end
  end
end
