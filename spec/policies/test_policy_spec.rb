# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'school staff for tests' do
  it 'scopes to current & past course tests' do
    course.save && user.save
    user.organisation.plans.create(attributes_for(:plan, course_id: course.id, start: 1.week.ago))
    past_test = create(:test, name: 'Past Test', course_tests:
                       [create(:course_test, course_id: course.id, week: 1)])
    current_test = create(:test, name: 'Current Test', course_tests:
                          [create(:course_test, course_id: course.id, week: 2)])
    create(:test, name: 'Future Test',
                  course_tests: [create(:course_test, course_id: course.id, week: 3)])
    create(:test, name: 'Spare Test')
    expect(Pundit.policy_scope!(user, Test)).to eq([past_test, current_test])
  end
end

RSpec.describe TestPolicy do
  subject(:policy) { described_class.new(user, course) }

  let(:course) { build(:course) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all tests' do
      tests = create_list(:test, 2)
      expect(Pundit.policy_scope!(user, Test)).to eq(tests)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      create_list(:test, 2)
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      create_list(:test, 2)
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'
    it_behaves_like 'school staff for tests'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'
    it_behaves_like 'school staff for tests'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'
    it_behaves_like 'school staff for tests'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end
end
