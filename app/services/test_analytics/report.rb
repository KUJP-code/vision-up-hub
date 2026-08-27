# frozen_string_literal: true

module TestAnalytics
  class Report
    SKILLS = %i[listen_percent read_percent write_percent speak_percent].freeze
    attr_reader :results

    def initialize(results)
      @results = results.to_a
    end

    def summary
      {
        results: results.size,
        students: results.map(&:student_id).uniq.size,
        schools: results.map(&:school_id).uniq.size,
        average: average(results, :total_percent),
        improved: movement_counts[:improved],
        maintained: movement_counts[:maintained],
        declined: movement_counts[:declined],
        override_rate: percentage(results.count { |result| result.new_level != result.recommended_level }, results.size)
      }
    end

    def skill_averages
      SKILLS.to_h { |skill| [skill, average(results, skill)] }
    end

    def school_rows
      results.group_by(&:school).map do |school, group|
        row_for(group).merge(name: school.name, organisation: school.organisation.name)
      end.sort_by { |row| [-row[:average], row[:name]] }
    end

    def test_rows
      results.group_by(&:test).map do |test, group|
        row_for(group).merge(name: test.name)
      end.sort_by { |row| [-row[:results], row[:name]] }
    end

    def student_rows
      results.group_by(&:student).flat_map do |student, group|
        ordered = group.sort_by(&:tested_on)
        ordered.each_with_index.map do |result, index|
          previous = index.positive? ? ordered[index - 1] : nil
          {
            date: result.tested_on,
            student: student.name,
            student_id: student.student_id,
            school: result.school.name,
            test: result.test.name,
            score: result.total_percent,
            change: previous ? result.total_percent - previous.total_percent : nil,
            previous_level: result.prev_level.titleize,
            new_level: result.new_level.titleize
          }
        end
      end.sort_by { |row| [row[:date], row[:student]] }.reverse
    end

    def progress_chart
      months = results.map { |result| result.tested_on.beginning_of_month }.uniq.sort
      grouped = results.group_by(&:school)
      {
        labels: months.map { |month| month.strftime('%b %Y') },
        datasets: grouped.map.with_index do |(school, group), index|
          {
            label: school.name,
            data: months.map { |month| average(group.select { |result| result.tested_on.beginning_of_month == month }, :total_percent) },
            borderColor: chart_colors[index % chart_colors.length],
            backgroundColor: chart_colors[index % chart_colors.length],
            tension: 0.3,
            spanGaps: true
          }
        end
      }
    end

    def distribution_chart
      labels = %w[0–19 20–39 40–59 60–79 80–100]
      counts = Array.new(5, 0)
      results.each { |result| counts[[result.total_percent / 20, 4].min] += 1 }
      { labels:, datasets: [{ label: 'Results', data: counts, backgroundColor: '#19B2D1' }] }
    end

    def school_comparison_chart
      rows = school_rows
      {
        labels: rows.map { |row| "#{row[:name]} (#{row[:results]})" },
        datasets: [{
          label: 'Average score',
          data: rows.map { |row| row[:average] },
          backgroundColor: rows.each_index.map { |index| chart_colors[index % chart_colors.length] },
          borderRadius: 5
        }]
      }
    end

    def school_chart_min
      scores = school_rows.filter_map { |row| row[:average] }
      return 0 if scores.blank?

      [((scores.min - 10) / 10).floor * 10, 0].max
    end

    def school_chart_height
      [school_rows.size * 38 + 60, 280].max
    end

    private

    def row_for(group)
      movements = movement_counts(group)
      {
        students: group.map(&:student_id).uniq.size,
        results: group.size,
        average: average(group, :total_percent),
        listening: average(group, :listen_percent),
        reading: average(group, :read_percent),
        writing: average(group, :write_percent),
        speaking: average(group, :speak_percent),
        improved_rate: percentage(movements[:improved], group.size),
        override_rate: percentage(group.count { |result| result.new_level != result.recommended_level }, group.size)
      }
    end

    def movement_counts(group = results)
      group.each_with_object({ improved: 0, maintained: 0, declined: 0 }) do |result, counts|
        previous = Levels::LEVEL_ORDER_MAP[result.prev_level]
        current = Levels::LEVEL_ORDER_MAP[result.new_level]
        next counts[:maintained] += 1 unless previous && current

        counts[current > previous ? :improved : current < previous ? :declined : :maintained] += 1
      end
    end

    def average(group, attribute)
      values = group.filter_map { |result| result.public_send(attribute) }
      values.any? ? (values.sum.to_f / values.size).round(1) : nil
    end

    def percentage(part, whole)
      whole.positive? ? (part.to_f / whole * 100).round(1) : 0
    end

    def chart_colors
      %w[#00ADCF #645880 #E9878A #ABC978 #F99C71 #8191ED #C08AC2 #007693]
    end
  end
end
