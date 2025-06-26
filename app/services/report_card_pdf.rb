class ReportCardPdf
  def initialize(student, user)
    @student, @user = student, user
  end

  def call
    html = render_html
    Grover.new(
      html,
      format:     'A4',
      emulate_media: 'print',        # use @media print rules
      wait_until:    'networkidle0', # all assets loaded
      evaluate: wait_for_chart_ready
    ).to_pdf
  end

  private

  def render_html
    env = { 'warden' => Warden::Proxy.new({}, Warden::Manager.new(nil)) }
    env['warden'].set_user(@user, scope: :user)

    ApplicationController.renderer.new(env).render(
      template: 'students/print_version',   # ← your existing file!
      layout:   'application',              # same layout parents see
      assigns: {
        student:       @student,
        levels:        Student.display_levels,
        results:       @student.test_results.order(created_at: :desc).includes(:test),
        active_result: @student.test_results.first
      },
      locals: { pdf_mode: true }            # use if you want `.print:hidden` tweaks
    )
  end

  def wait_for_chart_ready
    <<~JS
      () => new Promise(r => {
        const check = () => { window.chartReady ? r() : setTimeout(check, 50) }
        check();
      })
    JS
  end
end
