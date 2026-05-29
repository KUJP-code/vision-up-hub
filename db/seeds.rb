require 'factory_bot_rails'
fb = FactoryBot

puts 'Adding test files...'

File.open(Rails.root.join('spec/example_lesson.pdf')) do |f|
  ActiveStorage::Blob.create_and_upload!(
    io: f,
    filename: 'example_lesson.pdf',
    content_type: 'application/pdf'
  )
end
test_file = ActiveStorage::Blob.find_by(filename: 'example_lesson.pdf')

puts 'Creating features...'

features = %i[elementary keep_up kindy specialist teacher_tools]

features.each do |feature|
  Flipper.enable(feature)
end

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
                        name: 'Jayson',
                        email: 'admin@gmail.com',
                        password: 'Adminadminadmin1',
                        organisation_id: kids_up.id
                      ))

User::TYPES.each do |type|
  underscored = type.parameterize(separator: '_')
  User.create!(fb.attributes_for(
                 :user,
                 type.underscore.to_sym,
                 name: "Test #{type}",
                 email: "#{underscored}@example.com",
                 password: "#{type}Password1",
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

%i[kindy elementary].each do |level|
  fb.create(:daily_activity, level:, **released_attrs)
  fb.create(:exercise, level:, **released_attrs)
end

fb.create(:kindy_phonic, **released_attrs)

%i[kindy land_one sky_one galaxy_one].each do |level|
  fb.create(:english_class, level:, **released_attrs)
  fb.create(:phonics_class, level:, **released_attrs)
  fb.create(:stand_show_speak, level:, **released_attrs) unless level == :kindy
end

PhonicsClass.find_by(level: :kindy).destroy

evening_class_seeds = {
  keep_up_one: [
    { subtype: :conversation_time, title: 'Keep Up Conversation Time', goal: 'Build confidence through guided speaking prompts.' },
    { subtype: :topic_study, title: 'Keep Up Topic Study', goal: 'Practice key vocabulary and expressions around the weekly theme.' },
    { subtype: :special_lesson, title: 'Keep Up Special Lesson', goal: 'Apply the weekly language focus in a mixed review lesson.' }
  ],
  keep_up_two: [
    { subtype: :conversation_time, title: 'Keep Up 2 Conversation Time', goal: 'Extend speaking turns and peer interaction.' },
    { subtype: :topic_study, title: 'Keep Up 2 Topic Study', goal: 'Deepen comprehension of the current topic through reading and discussion.' }
  ]
}

evening_class_seeds.each do |level, lessons|
  lessons.each do |attrs|
    fb.create(:evening_class, level:, **attrs, **released_attrs)
  end
end

specialist_evening_class_seeds = {
  specialist: {
    title: 'Specialist Evening Class',
    literacy_goal: 'Develop close reading and response writing skills.',
    discussion_goal: 'Support structured opinions and follow-up questioning.',
    project_session_1_goal: 'Launch the project and organize research tasks.',
    project_session_2_goal: 'Refine ideas and prepare a project outcome.',
    special_lesson_goal: 'Blend review, challenge work, and presentation practice.'
  },
  specialist_advanced: {
    title: 'Specialist Advanced Evening Class',
    literacy_goal: 'Analyze longer texts and justify responses with evidence.',
    discussion_goal: 'Practice extended discussion with rebuttal and support.',
    project_session_1_goal: 'Plan a research-driven project with clear roles.',
    project_session_2_goal: 'Finalize and present the project with polished output.',
    special_lesson_goal: 'Stretch review work into a polished challenge lesson.'
  }
}

specialist_evening_class_seeds.each do |level, attrs|
  lesson = EveningClass.new(level:, subtype: nil, type: 'EveningClass', goal: attrs[:title], **attrs, **released_attrs)
  lesson.save!(validate: false)
end

Lesson.all.each do |lesson|
  lesson.attach_guide
end

Lesson.where(type: %w[EnglishClass StandShowSpeak KindyPhonic]).each do |lesson|
  lesson.guide.attach(test_file)
end

puts 'Adding homework files to English classes...'

Lesson.where(type: 'EnglishClass')
      .where.not(level: Lesson.levels[:kindy])
      .find_each do |lesson|
  lesson.homework_sheet.attach(test_file) unless lesson.homework_sheet.attached?
  lesson.homework_answers.attach(test_file) unless lesson.homework_answers.attached?
end

puts 'Creating category resources...'

CategoryResource.lesson_categories.keys.each do |lc|
  next if lc == 'english_class'

  CategoryResource.resource_categories.keys.each do |rc|
    category_resource = CategoryResource.new(
      lesson_category: lc,
      resource_category: rc,
      resource: test_file
    )
    category_resource.save if category_resource.valid?
  end
end


puts 'Creating courses...'

full_course = Course.create!(fb.attributes_for(:course, title: 'Full Course'))
full_course.category_resources << CategoryResource.all

lesson_days = CourseLesson::DAY_SHORTCUTS['all_week']
weekday_evening_schedule = {
  keep_up_one: {
    monday: %w[conversation_time topic_study special_lesson],
    tuesday: %w[conversation_time],
    wednesday: %w[topic_study],
    thursday: %w[special_lesson],
    friday: %w[conversation_time topic_study]
  },
  keep_up_two: {
    monday: %w[conversation_time topic_study],
    tuesday: %w[topic_study],
    wednesday: %w[conversation_time],
    thursday: %w[topic_study],
    friday: %w[conversation_time]
  },
  specialist: {
    monday: %w[literacy discussion project_session_1 project_session_2 special_lesson],
    tuesday: %w[literacy discussion],
    wednesday: %w[project_session_1],
    thursday: %w[project_session_2],
    friday: %w[special_lesson discussion]
  },
  specialist_advanced: {
    monday: %w[literacy discussion project_session_1 project_session_2 special_lesson],
    tuesday: %w[discussion],
    wednesday: %w[literacy project_session_1],
    thursday: %w[project_session_2],
    friday: %w[special_lesson]
  }
}.freeze

course_lessons = Lesson.all.map do |lesson|
  lesson.update(creator_id: 1, assigned_editor_id: writer.id)
  if lesson.type == 'EveningClass'
    lesson_days.filter_map do |day|
      day_key = day.to_sym
      if lesson.specialist_structured?
        next unless weekday_evening_schedule.fetch(lesson.level.to_sym).fetch(day_key, [])
                                              .any? { |subtype| lesson.specialist_subtype_present?(subtype) }
      else
        next unless weekday_evening_schedule.fetch(lesson.level.to_sym).fetch(day_key, [])
                                              .include?(lesson.subtype)
      end

      fb.create(:course_lesson, lesson:, course: full_course, week: 1, day:)
    end
  else
    lesson_days.map do |day|
      fb.create(:course_lesson, lesson:, course: full_course, week: 1, day:)
    end
  end
end

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

Exercise.find_by(level: :kindy).course_lessons.where.not(day: %w[monday tuesday]).destroy_all
DailyActivity.find_by(level: :kindy).course_lessons.where(day: %w[monday tuesday]).destroy_all

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

Test.all.each do |test|
  full_course.course_tests.create!(test_id: test.id, week: 1)
end

Student.all.each do |student|
  student.update(level: Student.levels.keys.sample)
end

puts 'Creating Tutorials...'

File.open(Rails.root.join('app/assets/icons/back.svg')) do |f|
  ActiveStorage::Blob.create_and_upload!(
    io: f,
    filename: 'tutorials_test_icon.svg',
    content_type: 'image/svg+xml'
  )
end
test_svg = ActiveStorage::Blob.find_by(filename: 'tutorials_test_icon.svg')

['Extra Resources', 'LMS Functions', 'Lessons'].each do |title|
  category = fb.build(:tutorial_category, title:)
  # category.svg.attach(test_svg)
  category.save
end

TutorialCategory.all.each do |category|
  fb.create_list(:pdf_tutorial, 2, tutorial_category_id: category.id)
  fb.create_list(:video_tutorial, 2, tutorial_category_id: category.id)
  fb.create_list(:faq_tutorial, 2, tutorial_category_id: category.id)
end

PrivacyPolicy.create!(version: "2025-07-03", content: "Initial privacy policy…")

puts 'Done!'
