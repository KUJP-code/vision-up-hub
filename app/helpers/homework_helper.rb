module HomeworkHelper

  def render_homework_rows(homeworks)
    return '' if homeworks.blank?
  
    grouped = homeworks.group_by(&:week)
  
    grouped.map do |week, hws|
      content_tag(:tr) do
        concat(content_tag(:td, week_range_text(week), class: 'p-2'))
        concat(content_tag(:td, class: 'p-2') do
          content_tag(:div, class: 'flex flex-col sm:flex-row gap-2 w-full') do
            hws.map { |hw| homework_buttons(hw) }.join.html_safe
          end
        end)
      end
    end.join.html_safe
  end

  private

  def week_range_text(week)
    monday = Date.current.beginning_of_year + (week - 1).weeks
    sunday = monday.end_of_week(:sunday)
    "#{monday.strftime('%b %d')} - #{sunday.strftime('%b %d')}"
  end

  def homework_buttons(hw)
    buttons = []
    buttons << homework_link(hw.questions, t('.questions'), 'btn btn-secondary') if hw.questions.attached?
    buttons << homework_link(hw.answers, t('.answers'), 'btn btn-danger') if hw.answers.attached?
    buttons.join
  end


  def homework_link(file, label, btn_class)
    link_to url_for(file), target: '_blank', rel: 'noopener', class: "#{btn_class} resource flex items-center justify-center gap-2 flex-1" do
      content_tag(:span, label) + inline_svg_tag('download_icon.svg', class: 'fill-white')
    end
  end
end
