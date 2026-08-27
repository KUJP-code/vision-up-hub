# frozen_string_literal: true

class TestAnalyticsController < ApplicationController
  before_action :authorize_analytics
  before_action :set_filters

  def index
    unless @selected_test
      @overview = TestAnalytics::SchoolOverview.new(base_results)
      @overview_reports = overview_windows.map do |label, start_date|
        [label, TestAnalytics::SchoolOverview.new(base_results, since: start_date, period: label)]
      end
      return
    end

    results = dashboard_results
    @report = TestAnalytics::Report.new(primary_results(results))
  end

  def export
    return redirect_to(analytics_tests_path, alert: 'Select a test before exporting.') unless @selected_test

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
    @tests = Test.order(created_at: :desc, id: :desc)
    @selected_test = @tests.find { |test| test.id == params[:test_id].to_i } if params[:test_id].present?
  end

  def base_results
    scope = TestResult.where(organisation_id: @organisation.id)
    scope = scope.where(test_id: @selected_test.id) if @selected_test
    scope
  end

  def dashboard_results
    base_results.includes(:student, :test, school: :organisation)
                .where(tested_on: 5.years.ago.to_date..Date.current)
                .order(:tested_on).to_a
  end

  def primary_results(results = dashboard_results)
    recent = results.select { |result| result.tested_on >= 3.months.ago.to_date }
    if recent.any?
      @reporting_period = 'Last 3 months'
      return recent
    end

    latest_date = results.map(&:tested_on).max
    return [] if latest_date.blank?

    @reporting_period = "Latest test set · #{latest_date.strftime('%B %Y')}"
    results.select { |result| result.tested_on.in?(latest_date.all_month) }
  end

  def overview_windows
    [
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
