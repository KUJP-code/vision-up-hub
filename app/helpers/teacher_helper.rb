# frozen_string_literal: true

module TeacherHelper
  def day_link_classes(active, day)
    past = day < Time.zone.today
    'flex flex-col items-center rounded-3xl p-2 ' \
      "#{active ? 'bg-color-main' : 'bg-color-secondary'} #{'opacity-50' if past}"
  end

  def day_link_date_classes(active)
    'flex items-center justify-center rounded-full aspect-square bg-white ' \
      "font-bold text-xl p-2 #{active ? 'text-color-main' : 'text-color-secondary'}"
  end
end
