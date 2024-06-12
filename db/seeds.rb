require 'factory_bot_rails'
fb = FactoryBot

puts 'Creating organisations...'

kids_up = Organisation.create!(fb.attributes_for(:organisation, name: 'KidsUP'))
test_org = Organisation.create!(fb.attributes_for(:organisation, name: 'Test Org'))
fb.create_list(:organisation, 2)

Organisation.all.each do |org|
  org.schools << fb.create_list(:school, 2, ip: '*')
end

puts 'Creating users...'

admin = Admin.create!(fb.attributes_for(
                        :user,
                        :admin,
                        name: 'Brett',
                        email: 'admin@gmail.com',
                        password: 'adminadminadmin',
                        organisation_id: kids_up.id
                      ))

User::TYPES.each do |type|
  underscored = type.parameterize(separator: '_')
  User.create!(fb.attributes_for(
                 :user,
                 type.underscore.to_sym,
                 name: "Test #{type}",
                 email: "#{underscored}@example.com",
                 password: "#{underscored}password",
                 organisation_id: kids_up.id
               ))
end

Teacher.create!(fb.attributes_for(:user, :teacher, organisation_id: 2))

SchoolManager.all.each do |manager|
  manager.schools << manager.organisation.schools.first
end

writer = Writer.first

puts 'Creating user complaints...'

User.all.each do |user|
  request = fb.create(:support_request, user:)
  request.messages.create!(fb.attributes_for(:support_message, user:))
end

puts "Creating today's lessons..."

released_attrs = { released: true, status: :accepted,
                   admin_approval: [{ id: admin.id, name: admin.name }] }

Lesson::TYPES.map do |type|
  puts "Creating #{type}..."
  Lesson.create!(fb.attributes_for(type.underscore.to_sym).merge(released_attrs))
end

%i[land_two sky_three galaxy_one].each do |level|
  fb.create(:english_class, level:, **released_attrs)
  fb.create(:phonics_class, level:, **released_attrs)
  fb.create(:stand_show_speak, level:, **released_attrs)
end

Lesson.all.each do |lesson|
  lesson.attach_guide
  lesson.proposals << fb.create( lesson.type.underscore.to_sym, :proposal)
end

Lesson.where(type: %w[EnglishClass StandShowSpeak]).each do |lesson|
  lesson.guide.attach(File.open(Rails.root.join('spec/Brett_Tanner_Resume.pdf')))
end

puts 'Creating courses...'

course_lessons = Lesson.all.map do |lesson|
  lesson.update(creator_id: 1, assigned_editor_id: writer.id)
  fb.build(:course_lesson, lesson:, week: 1, day: Time.zone.today.strftime('%A').downcase)
end

Course.create!(fb.attributes_for(:course, title: 'Full Course', course_lessons:))
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

puts 'Adding parents, and students to classes and schools...'

School.all.each do |school|
  parent = fb.create(:user, :parent, organisation_id: school.organisation_id)
  students = fb.create_list(:student, 2, school_id: school.id, parent_id: parent.id)
  school.classes.each do |klass|
    klass.students << students
  end
  fb.create(:student, school_id: school.id, name: 'Orphan')
end

puts 'Creating a level check and test result...'

level_check = fb.create(
  :test,
  questions: "writing: 2, 3, 4\nreading: 5, 4 \nlistening: 2, 3, 6 \nspeaking: 10",
  thresholds: "Sky One:60\nSky Two:70\nSky Three:80"
)

fb.create_list(:test, 5)
rand_test = Test.last

results = [
  fb.attributes_for(
    :test_result,
    test_id: level_check.id,
    prev_level: :sky_one,
    new_level: :sky_two,
    read_percent: rand(0..100),
    write_percent: rand(0..100),
    speak_percent: rand(0..100),
    listen_percent: rand(0..100),
    reason: 'I am a reason',
    answers: {
      'writing' => [2, 3, 1],
      'reading' => [5, 0],
      'listening' => [2, 1, 6],
      'speaking' => [10]
    }
  ),
  fb.attributes_for(
    :test_result,
    test_id: rand_test.id,
    prev_level: :sky_one,
    new_level: :sky_three,
    read_percent: rand(0..100),
    write_percent: rand(0..100),
    speak_percent: rand(0..100),
    listen_percent: rand(0..100),
    answers: {
      'writing' => [2, 3, 4],
      'reading' => [5, 4],
      'listening' => [2, 3, 6],
      'speaking' => [10]
    }
  )
]

Student.all.each do |student|
  results.each do |result|
    student.test_results.create!(result)
  end
end

Student.all.each do |student|
  student.update(level: Student.levels.keys.sample)
end

puts 'Done!'
