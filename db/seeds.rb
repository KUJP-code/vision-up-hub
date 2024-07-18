require 'factory_bot_rails'
fb = FactoryBot

File.open(Rails.root.join('spec/Brett_Tanner_Resume.pdf')) do |f|
  ActiveStorage::Blob.create_and_upload!(
    io: f,
    filename: 'Brett_Tanner_Resume.pdf',
    content_type: 'application/pdf'
  )
end
test_file = ActiveStorage::Blob.find_by(filename: 'Brett_Tanner_Resume.pdf')

puts 'Creating organisations...'

kids_up = Organisation.create!(fb.attributes_for(:organisation, name: 'KidsUP'))
test_org = Organisation.create!(fb.attributes_for(:organisation, name: 'Test Org'))

I18n.with_locale(:ja) do
  I18n.t('school_names').each do |name, _|
    fb.create(:school, name:, organisation_id: kids_up.id, ip: '*')
  end
end

Organisation.all.except(kids_up).each do |org|
  org.schools << fb.create_list(:school, 2)
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

Teacher.create!(fb.attributes_for(:user, :teacher,
                                  organisation_id: test_org.id))

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

Lesson::TYPES.each do |type|
  next if type == 'PhonicsClass'

  puts "Creating #{type}..."
  lesson = Lesson.create!(
    fb.attributes_for(type.underscore.to_sym)
    .merge(released_attrs)
  )
end

%i[land_one sky_one galaxy_one].each do |level|
  fb.create(:english_class, level:, **released_attrs)
  fb.create(:phonics_class, level:, **released_attrs)
  fb.create(:stand_show_speak, level:, **released_attrs)
end

Lesson.all.each do |lesson|
  lesson.attach_guide
  lesson.proposals << fb.create( lesson.type.underscore.to_sym, :proposal)
end

Lesson.where(type: %w[EnglishClass StandShowSpeak]).each do |lesson|
  lesson.guide.attach(test_file)
end

puts 'Creating category resources...'

CategoryResource.lesson_categories.keys.each do |lc|
  CategoryResource.resource_categories.keys.each do |rc|
    category_resource = CategoryResource.new(lesson_category: lc,
                                             resource_category: rc,
                                             resource: test_file)
    next unless category_resource.valid?

    category_resource.save
  end
end

puts 'Creating courses...'

course_lessons = Lesson.all.map do |lesson|
  lesson.update(creator_id: 1, assigned_editor_id: writer.id)
  fb.build(:course_lesson, lesson:, week: 1, day: Time.zone.today.strftime('%A').downcase)
end

full_course = Course.create!(fb.attributes_for(:course, title: 'Full Course', course_lessons:))
full_course.category_resources << CategoryResource.all

Organisation.all.each do |org|
  org.plans.create!(fb.attributes_for(
                      :plan, course_id: Course.first.id,
                             start: Date.today.beginning_of_week
                    ))
end
empty_course = Course.create!(fb.attributes_for(:course, title: 'Empty Course'))
kids_up.plans.create!(
  fb.attributes_for(:plan, course_id: empty_course.id, start: Date.today.beginning_of_week)
)

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
  students = fb.create_list(:student, 2, school_id: school.id,
                                         parent_id: parent.id)
  school.classes.each do |klass|
    klass.students << students
  end
  fb.create(:student, school_id: school.id, name: 'Orphan')
end

puts 'Creating level checks'

level_check = fb.create(
  :test,
  basics: 2,
  questions: "writing: 2, 3, 4\nreading: 5, 4 \nlistening: 2, 3, 6 \nspeaking: 10",
  thresholds: "Sky One:60\nSky Two:70\nSky Three:80"
)

fb.create_list(:test, 2, basics: 2)

Student.all.each do |student|
  student.update(level: Student.levels.keys.sample)
end

puts 'Done!'
