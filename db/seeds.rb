require 'factory_bot_rails'
fb = FactoryBot

puts 'Creating organisations...'

kids_up = Organisation.create!(fb.attributes_for(:organisation, name: 'KidsUP'))
test_org = Organisation.create!(fb.attributes_for(:organisation, name: 'Test Org'))
fb.create_list(:organisation, 2)

Organisation.all.each do |org|
  org.schools << fb.create_list(:school, 2)
end

puts 'Creating users...'

Admin.create!(fb.attributes_for(
  :user,
  :admin,
  name: 'Brett',
  email: 'admin@gmail.com',
  password: 'adminadminadmin',
  organisation_id: kids_up.id
))

User::TYPES.each do |type|
  org = %w[Admin Sales Writer Teacher].include?(type) ? kids_up : test_org
  underscored = type.parameterize(separator: '_')
  User.create!(fb.attributes_for(
    :user,
    type.underscore.to_sym,
    name: "Test #{type}",
    email: "#{underscored}@example.com",
    password: "#{underscored}password",
    organisation_id: org.id
  ))
end

Teacher.create!(fb.attributes_for(:user, :teacher, organisation_id: 2))

SchoolManager.all.each do |manager|
  manager.schools << manager.organisation.schools.first
end

writer = Writer.first

Lesson::TYPES.map do |type|
  puts "Creating #{type}..."
  l = Lesson.create!(fb.attributes_for(
    type.underscore.to_sym,
    assigned_editor_id: writer.id,
    creator_id: 1
  ))
end

puts "Creating today's lessons..."

%i[land_two sky_three galaxy_one].each do |level|
  fb.create(:english_class, level: level)
  fb.create(:phonics_class, level: level)
  fb.create(:stand_show_speak, level: level)
end

Lesson.all.each do |lesson|
  lesson.attach_guide
end

Lesson.where(type: %w[EnglishClass StandShowSpeak]).each do |lesson|
  lesson.guide.attach(File.open(Rails.root.join('spec', 'Brett_Tanner_Resume.pdf')))
end

puts 'Creating courses...'

course_lessons = Lesson.all.map { |lesson| fb.build(:course_lesson, lesson: lesson, week: 1, day: Time.zone.today.strftime('%A').downcase) }

Course.create!(fb.attributes_for(:course, title: 'Full Course', course_lessons: course_lessons))
Organisation.all.each do |org|
  org.create_plan!(fb.attributes_for(:plan, course_id: Course.first.id, start: Date.today.beginning_of_week))
end
Course.create!(fb.attributes_for(:course, title: 'Empty Course'))

puts 'Adding classes to schools & teachers...'

School.all.each do |school|
  school.classes << fb.build_list(:school_class, 2)
end

Teacher.all.each do |teacher|
  teacher.schools << teacher.organisation.schools.first
  teacher.classes << teacher.schools.first.classes.first
end

puts 'Adding students to classes and schools...'

School.all.each do |school|
  students = fb.create_list(:student, 10, school_id: school.id)
  school.classes.each do |klass|
    klass.students << students
  end
end

puts 'Creating a level check and test result...'

level_check = fb.create(
  :test,
  questions: "writing: 2, 3, 4\nreading: 5, 4 \nlistening: 2, 3, 6 \nspeaking: 10"
)
level_check.test_results << fb.create(:test_result, test: level_check, student: Student.first)

puts 'Done!'
