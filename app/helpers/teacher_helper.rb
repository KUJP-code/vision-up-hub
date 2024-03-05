# frozen_string_literal: true

module TeacherHelper
  def day_link_classes(active)
    "flex flex-col items-center rounded-3xl p-2 #{active ? 'bg-ku-orange' : 'bg-ku-purple'}"
  end

  def day_link_date_classes(active)
    'flex items-center justify-center rounded-full aspect-square bg-white ' \
      "font-bold text-xl p-2 #{active ? 'text-ku-orange' : 'text-ku-purple'}"
  end
end
