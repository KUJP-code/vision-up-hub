module HomeworkHelper

  def render_homework_rows(homeworks)
    return '' if homeworks.blank?

    grouped = homeworks.group_by { |resource| homework_week(resource) }.sort_by { |week, _| week.to_i }

    grouped.map do |week, hws|
      sheet = hws.lazy.map { |hw| homework_sheet(hw) }.find { |file| file&.attached? }
      answers = hws.lazy.map { |hw| homework_answers(hw) }.find { |file| file&.attached? }

      content_tag(:tr) do
        concat(content_tag(:td, week_range_text(week), class: 'p-2'))
        concat(content_tag(:td, class: 'p-2') do
          content_tag(:div, class: 'flex flex-col sm:flex-row gap-2 w-full') do
            homework_buttons(sheet, answers).html_safe
          end
        end)
      end
    end.join.html_safe
  end

  private

  def week_range_text(week)
    return '' unless defined?(@plan) && @plan.present?

    start_date = @plan.start.to_date + (week - 1).weeks
    end_date = start_date + 6.days

    "#{l(start_date, format: :short)} - #{l(end_date, format: :short)}"
  end

  def homework_buttons(sheet, answers)
    buttons = []
    buttons << homework_link(sheet, t('.questions'), 'btn btn-secondary') if sheet&.attached?
    buttons << homework_link(answers, t('.answers'), 'btn btn-danger') if answers&.attached?
    buttons.join
  end

  def homework_link(file, label, btn_class)
    link_to url_for(file), target: '_blank', rel: 'noopener', class: "#{btn_class} resource flex items-center justify-center gap-2 flex-1" do
      content_tag(:span, label) + inline_svg_tag('download_icon.svg', class: 'fill-white')
    end
  end

  def homework_week(resource)
    return resource.week if resource.respond_to?(:week)
    return resource.course_lesson.week if resource.respond_to?(:course_lesson)

    nil
  end

  def homework_sheet(resource)
    return resource.homework_sheet if resource.respond_to?(:homework_sheet)
    return resource.lesson.homework_sheet if resource.respond_to?(:lesson) && resource.lesson.respond_to?(:homework_sheet)
    return resource.questions if resource.respond_to?(:questions)

    nil
  end

  def homework_answers(resource)
    return resource.homework_answers if resource.respond_to?(:homework_answers)
    return resource.lesson.homework_answers if resource.respond_to?(:lesson) && resource.lesson.respond_to?(:homework_answers)
    return resource.answers if resource.respond_to?(:answers)

    nil
  end
end
