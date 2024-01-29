require 'factory_bot_rails'

daily_activity = FactoryBot.create(:daily_activity)
exercise = FactoryBot.create(:exercise)

course_lessons = [
    FactoryBot.build(:course_lesson, lesson: daily_activity),
    FactoryBot.build(:course_lesson, lesson: exercise)
]

FactoryBot.create(:course, course_lessons: course_lessons)
FactoryBot.create(:course)
