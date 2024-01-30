require 'factory_bot_rails'

kids_up = FactoryBot.create(:organisation, name: 'KidsUP')
FactoryBot.create_list(:organisation, 5)

FactoryBot.create(
  :user,
  :admin,
  email: 'admin@gmail.com',
  password: 'adminadminadmin',
  organisation: kids_up
)

User::TYPES.each do |type|
  org = %w[Admin Sales Writer].include?(type) ? kids_up : FactoryBot.create(:organisation)
  underscored = type.parameterize(separator: '_')
  FactoryBot.create(
    :user,
    type: type,
    email: "#{underscored}@example.com",
    password: "#{underscored}password",
    organisation: org
  )
end

daily_activity = FactoryBot.create(:daily_activity)
exercise = FactoryBot.create(:exercise)

Lesson.all.each(&:save_guide)

course_lessons = [
    FactoryBot.build(:course_lesson, lesson: daily_activity),
    FactoryBot.build(:course_lesson, lesson: exercise)
]

FactoryBot.create(:course, course_lessons: course_lessons)
FactoryBot.create(:course)
