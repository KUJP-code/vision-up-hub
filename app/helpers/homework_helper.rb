module HomeworkHelper
  def unique_homework_by_date(homework_list)
    homework_list.uniq { |hw| hw.id }.group_by { |hw| hw.date_for(@student.organisation) }
  end

  def filter_by_date(homework_list)
    current_date = Date.current
    start_date = current_date - 3.weeks
    end_date = current_date + 3.weeks

    homework_list.select do |resource|
      date_for_resource = resource.date_for(@student.organisation)
      date_for_resource && date_for_resource.between?(start_date, end_date)
    end
  end

  def render_homework_rows(homework_list)
    filtered_homework = filter_by_date(homework_list)
    grouped_homework = unique_homework_by_date(filtered_homework)

    grouped_homework.map do |date, resources|
      content_tag :tr do
        monday = date.beginning_of_week(:monday)
        sunday = date.end_of_week(:sunday)

        week_range = "#{monday.strftime('%b %d')} - #{sunday.strftime('%b %d')}"

        concat(content_tag(:td, week_range, class: 'p-2'))
        concat(content_tag(:td, class: 'p-2') do
          content_tag(:div, class: 'flex gap-4 justify-between') do
            resources.map do |resource|
              button_class = resource.is_answers? ? 'btn btn-main' : 'btn btn-secondary'
              button_text = resource.is_answers? ? t('.answers') : t('.open')

              link_to file_path(resource.blob), target: '_blank', rel: 'noopener',
                                                class: "#{button_class} resource flex-1 flex justify-center" do
                content_tag(:p, button_text) + inline_svg_tag('download_icon.svg', class: 'fill-white')
              end
            end.join.html_safe
          end
        end)
      end
    end.join.html_safe
  end
end
