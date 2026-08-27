# frozen_string_literal: true

class TestAnalytics::SchoolOverview
  COLORS = %w[#00ADCF #645880 #E9878A #ABC978 #F99C71 #8191ED #C08AC2 #007693].freeze

  attr_reader :period

  def initialize(scope, since: nil, period: nil)
    @scope = scope
    @results = since ? @scope.where(tested_on: since..Date.current) : overview_scope
    @period = period if period
  end

  def any?
    rows.any?
  end

  def chart_data
    overall_average = @results.average(:total_percent)&.round(1)
    {
      labels: rows.map { |row| "#{row[:name]} — #{TestAnalytics::SchoolName.result_count(row[:results])}" },
      datasets: [
        {
          label: 'School average',
          data: rows.map { |row| row[:average] },
          backgroundColor: rows.each_index.map { |index| COLORS[index % COLORS.length] },
          borderRadius: 5
        },
        {
          type: 'line',
          label: "All-school average · #{overall_average}%",
          data: rows.map { overall_average },
          borderColor: '#191919',
          borderDash: [7, 5],
          borderWidth: 2,
          pointRadius: 0,
          tension: 0
        }
      ]
    }
  end

  def chart_min
    return 0 if rows.empty?

    [((rows.last[:average] - 10) / 10).floor * 10, 0].max
  end

  def chart_height
    [rows.size * 38 + 60, 280].max
  end

  private

  def overview_scope
    recent = @scope.where(tested_on: 3.months.ago.to_date..Date.current)
    if recent.exists?
      @period = 'Last 3 months'
      return recent
    end

    latest_date = @scope.maximum(:tested_on)
    return @scope.none if latest_date.blank?

    @period = "Latest test set · #{latest_date.strftime('%B %Y')}"
    @scope.where(tested_on: latest_date.all_month)
  end

  def rows
    @rows ||= @results.joins(:school)
                      .group('schools.id', 'schools.name')
                      .pluck('schools.name', Arel.sql('COUNT(test_results.id)'), Arel.sql('AVG(test_results.total_percent)'))
                      .map do |name, count, average|
                        { name: TestAnalytics::SchoolName.english(name), results: count, average: average.to_f.round(1) }
                      end
                      .sort_by { |row| [-row[:average], row[:name]] }
  end
end
