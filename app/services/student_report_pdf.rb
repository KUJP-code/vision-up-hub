class StudentReportPdf
  include Rails.application.routes.url_helpers

  def initialize(student, pearson = false, **options)
    @student = student

    raw_flag = options.key?(:pearson) ? options[:pearson] : pearson
    @pearson_mode = cast_boolean(raw_flag)
  end

  def call(browser: nil)
    html = ApplicationController.render(
      template: template_name,
      layout: 'pdf',
      assigns: render_assigns
    )

    render_pdf(html, browser:)
  end

  private

  attr_reader :student

  def render_assigns
    pearson_mode? ? pearson_assigns : standard_assigns
  end

  def standard_assigns
    results        = student.test_results.includes(:test)
                            .order(created_at: :desc)
    active_result  = nil
    recent_result  = results.first

    {
      student:,
      results:,
      active_result:,
      recent_result:,
      data: radar_data(results, active_result),
      levels: Student.display_levels,
      pearson_data: {}
    }
  end

  def pearson_assigns
    results = student.pearson_results.latest_per_test
    chart_data, active_result, recent_result = pearson_chart_data(results)

    {
      student:,
      results:,
      active_result:,
      recent_result:,
      data: chart_data,
      levels: Student.display_levels,
      pearson_data: {
        results:,
        active_result:,
        recent_result:,
        data: chart_data
      }
    }
  end

  def radar_data(results, active_result)
    radar_colors = ['49, 44, 180', '221, 50, 50', '170, 218, 120',
                    '178, 170, 191'].cycle

    datasets = if active_result
                 [prepare_dataset(active_result, radar_colors.next)]
               else
                 results.map { |r| prepare_dataset(r, radar_colors.next) }
               end

    { labels: %w[Reading Writing Listening], datasets: }
  end

  def prepare_dataset(result, color)
    {
      data: result.radar_data[:data],
      label: result.radar_data[:label],
      backgroundColor: "rgba(#{color},0.2)",
      pointBackgroundColor: '#645880',
      pointBorderColor: '#fff',
      pointHoverBackgroundColor: '#fff',
      pointHoverBorderColor: "rgb(#{color})"
    }
  end

  def pearson_mode?
    @pearson_mode
  end

  def template_name
    pearson_mode? ? 'students/pearson_print_version' : 'students/print_version'
  end

  def cast_boolean(val)
    ActiveModel::Type::Boolean.new.cast(val)
  end

  def pearson_chart_data(results)
    return [{ labels: [], datasets: [], chart_max: 0, tick_step: 10 }, nil, nil] if results.blank?

    radar_colors = ['49, 44, 180', '221, 50, 50', '170, 218, 120', '178, 170, 191'].cycle

    rows = results.first(4)

    ok_scores = rows.flat_map do |pr|
      [pr.listening_score, pr.reading_score, pr.writing_score, pr.speaking_score].compact
    end

    raw_max   = ok_scores.max || 0
    padded    = raw_max + 10
    rounded   = (padded / 10.0).ceil * 10
    chart_max = [[rounded, 40].max, 90].min

    datasets = rows.map { |pr| prepare_pearson_dataset(pr, radar_colors.next) }

    [
      {
        labels: %w[Listening Reading Writing Speaking],
        datasets:,
        chart_max:,
        tick_step: 10
      },
      nil,
      results.first
    ]
  end

  def prepare_pearson_dataset(pr, color)
    vals = [
      pr.listening_score || 0,
      pr.reading_score   || 0,
      pr.writing_score   || 0,
      pr.speaking_score  || 0
    ]

    label_date = pr.test_taken_at&.strftime('%Y-%m-%d')
    label_form = pr.form.present? ? " (#{pr.form})" : ''
    label = "#{pr.test_name} #{label_date}#{label_form}"

    {
      data: vals,
      label:,
      backgroundColor: "rgba(#{color}, 0.2)",
      pointBackgroundColor: '#645880',
      pointBorderColor: '#fff',
      pointHoverBackgroundColor: '#fff',
      pointHoverBorderColor: "rgb(#{color})"
    }
  end

  def default_host
    Rails.application.routes.default_url_options[:host] ||
      ENV.fetch('APP_HOST', 'http://localhost:3000')
  end

  def render_pdf(html, browser: nil)
    options = {
      format: 'A4',
      emulate_media: 'print',
      wait_for: 'window.chartReady === true',
      base_url: Rails.application.routes.default_url_options[:host]
    }

    grover_options = options.dup
    grover_options[:browser] = browser if browser

    Grover.new(html, **grover_options).to_pdf
  end
end
