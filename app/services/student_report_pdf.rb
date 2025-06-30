class StudentReportPdf
  include Rails.application.routes.url_helpers

  def initialize(student)
    @student = student
  end

  def call
    html = ApplicationController.render(
      template: 'students/print_version',
      layout:   'pdf',
      assigns:  render_assigns    # these keys become @ivars
    )

    Grover.new(
      html,
      format:        'A4',
      emulate_media: 'print',
      wait_for:      'window.chartReady === true',
      base_url:      default_host
    ).to_pdf
  end

  private

  attr_reader :student

  # --- identical to StudentsController#set_results -------------------------
  def render_assigns
    results        = student.test_results.includes(:test)
                           .order(created_at: :desc)
    active_result  = nil                                 # no “detail” view here
    recent_result  = results.first

    {
      student:        student,
      results:        results,
      active_result:  active_result,
      recent_result:  recent_result,
      data:           radar_data(results, active_result),
      levels:         Student.display_levels
    }
  end

  # mini-version of controller’s radar_data helper
  def radar_data(results, active_result)
    radar_colors = ['49, 44, 180', '221, 50, 50', '170, 218, 120',
                    '178, 170, 191'].cycle

    datasets = if active_result
                 [prepare_dataset(active_result, radar_colors.next)]
               else
                 results.map { |r| prepare_dataset(r, radar_colors.next) }
               end

    { labels: %w[Reading Writing Listening], datasets: datasets }
  end

  def prepare_dataset(result, color)
    {
      data:                        result.radar_data[:data],
      label:                       result.radar_data[:label],
      backgroundColor:             "rgba(#{color},0.2)",
      pointBackgroundColor:        '#645880',
      pointBorderColor:            '#fff',
      pointHoverBackgroundColor:   '#fff',
      pointHoverBorderColor:       "rgb(#{color})"
    }
  end
  # -------------------------------------------------------------------------

  def default_host
    Rails.application.routes.default_url_options[:host] ||
      ENV.fetch('APP_HOST', 'http://localhost:3000')
  end
end
