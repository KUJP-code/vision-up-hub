# frozen_string_literal: true

class ScreenMirroringTestsController < ApplicationController
  layout -> { %w[2.7.9.1 2.8.3.1].include?(params[:reference]) ? 'application' : 'lesson_prototype' }

  def show
    case params[:reference]
    when '2.7.9.1'
      render :reference
    when '2.8.3.1'
      render :reference_2831
    else
      @lesson_weeks = AiSenseiContent.weeks
    end
  end

  def layout_report
    return head :not_found unless Rails.env.local?
    return head 413 if request.raw_post.bytesize > 16_384

    report = params.require(:report).permit(
      :event, :visit, :user_agent, :platform, :touch_points, :standalone,
      dimensions: %i[inner_width inner_height client_width client_height scroll_x scroll_y screen_width screen_height dpr],
      viewport: %i[width height offset_top offset_left page_top page_left scale],
      safe_area: %i[top right bottom left],
      elements: %i[name top left width height bottom margin_top padding_top position overflow_y scroll_top scroll_height client_height]
    ).to_h.merge('recorded_at' => Time.current.iso8601)
    File.open(Rails.root.join("tmp/ai-sensei-layout-reports-#{Rails.env}.jsonl"), 'a') do |file|
      file.flock(File::LOCK_EX)
      file.puts(report.to_json)
    end
    head :no_content
  end
end
