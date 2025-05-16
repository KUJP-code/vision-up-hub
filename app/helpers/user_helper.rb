# frozen_string_literal: true

module UserHelper
  def viewing_self?
    User::TYPES.include?(controller_name.titleize.tr(' ', '').singularize) &&
      current_user.id == params[:id].to_i
  end

  def todays_lessons_link
    first_teacher = Teacher
      .joins(:schools)
      .where(schools: { id: current_user.schools.select(:id) })
      .first


    if first_teacher
      link_to organisation_teacher_path(id: first_teacher.id, organisation_id: current_user.organisation.id),
              class: 'btn btn-outline-white w-full flex gap-2' do
        inline_svg_tag('todays_lesson.svg', class: 'w-10 h-10') + t('.todays_lessons')
      end
    else
      # Fallback btn
      content_tag(:span, class: 'btn btn-outline-white w-full flex gap-2 cursor-not-allowed opacity-50') do
        inline_svg_tag('todays_lesson.svg', class: 'w-10 h-10') + ' Todays Lessons'.html_safe
      end
    end
  end
end
