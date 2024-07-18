# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'writer for LessonPolicy' do
  it_behaves_like 'fully authorized user'

  it 'scopes to all lessons' do
    expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.all)
  end
end

RSpec.describe LessonPolicy do
  subject(:policy) { described_class.new(user, lesson) }

  let(:lesson) { build(:daily_activity) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'writer for LessonPolicy'

    it 'scopes to all lessons' do
      expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.all)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'writer for LessonPolicy'

    it 'scopes to all lessons' do
      expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.all)
    end
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'

    it 'scopes to plan lessons' do
      course = create(:course)
      lesson = create(:daily_activity)
      lesson.course_lessons.create!(attributes_for(:course_lesson,
                                                   course_id: course.id))
      user.save
      user.organisation.plans.create!(
        attributes_for(:plan,
                       organisation: user.organisation,
                       course_id: course.id)
      )
      expect(Pundit.policy_scope!(user, Lesson)).to contain_exactly(lesson)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.none)
    end
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'

    it 'scopes to plan lessons' do
      course = create(:course)
      lesson = create(:daily_activity)
      lesson.course_lessons.create!(attributes_for(:course_lesson,
                                                   course_id: course.id))
      user.save
      user.organisation.plans.create!(
        attributes_for(:plan,
                       organisation: user.organisation,
                       course_id: course.id)
      )
      expect(Pundit.policy_scope!(user, Lesson)).to contain_exactly(lesson)
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to plan lessons' do
      course = create(:course)
      lesson = create(:daily_activity)
      lesson.course_lessons.create!(attributes_for(:course_lesson,
                                                   course_id: course.id))
      user.save
      user.organisation.plans.create!(
        attributes_for(:plan,
                       organisation: user.organisation,
                       course_id: course.id)
      )
      expect(Pundit.policy_scope!(user, Lesson)).to contain_exactly(lesson)
    end
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.none)
    end
  end
end
