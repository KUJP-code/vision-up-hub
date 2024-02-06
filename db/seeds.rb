require 'factory_bot_rails'
fb = FactoryBot

# Create organisations

kids_up = Organisation.create!(fb.attributes_for(:organisation, name: 'KidsUP'))
test_org = Organisation.create!(fb.attributes_for(:organisation, name: 'Test Org'))
fb.create_list(:organisation, 2)

Organisation.all.each do |org|
  org.schools << fb.create_list(:school, 2)
end

# Create users

Admin.create!(fb.attributes_for(
  :user,
  :admin,
  name: 'Brett',
  email: 'admin@gmail.com',
  password: 'adminadminadmin',
  organisation_id: kids_up.id
))

User::TYPES.each do |type|
  org = %w[Admin Sales Writer].include?(type) ? kids_up : test_org
  underscored = type.parameterize(separator: '_')
  User.create!(fb.attributes_for(
    :user,
    type.underscore.to_sym,
    email: "#{underscored}@example.com",
    password: "#{underscored}password",
    organisation_id: org.id,
    school_id: type == 'Teacher' ? org.schools.ids.first : nil
  ))
end

SchoolManager.all.each do |manager|
  manager.schools << manager.organisation.schools.first
end

# Create lessons

daily_activity = DailyActivity.create!(fb.attributes_for(:daily_activity))
exercise = Exercise.create!(fb.attributes_for(:exercise))

Lesson.all.each do |lesson|
  AttachGuideJob.perform_later(lesson)
end

# Create courses

course_lessons = [
    fb.build(:course_lesson, lesson: daily_activity),
    fb.build(:course_lesson, lesson: exercise)
]

Course.create!(fb.attributes_for(:course, course_lessons: course_lessons))
Course.create!(fb.attributes_for(:course))
