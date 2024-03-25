# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'fully authorized user for TestResult' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.describe TestResultPolicy do
  subject(:policy) { described_class.new(user, test_result) }

  let(:test) { create(:test) }

  let(:test_result) { build(:test_result, test:) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user for TestResult'

    it 'scopes to all test results' do
      expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.all)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
    end
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    context 'when admin of test result org' do
      before do
        school = create(:school, organisation: user.organisation)
        student = create(:student, school:)
        student.test_results << test_result
        user.save
      end

      it_behaves_like 'fully authorized user for TestResult'

      it 'scopes to org test results' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.all)
      end
    end

    context 'when not admin of test result org' do
      it_behaves_like 'unauthorized user'

      it 'scopes to nothing' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
      end
    end
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    context 'when manager of test result school' do
      before do
        school = create(:school, organisation: user.organisation)
        user.schools << school
        student = create(:student, school:)
        student.test_results << test_result
        user.save
      end

      it_behaves_like 'fully authorized user for TestResult'

      it 'scopes to school test results' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.all)
      end
    end

    context 'when not manager of test result school' do
      it_behaves_like 'unauthorized user'

      it 'scopes to nothing' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
      end
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    context 'when teacher of test results student class' do
      before do
        school_class = create(:school_class)
        student = create(:student)
        student.test_results << test_result
        student.classes << school_class
        user.classes << school_class
        user.save
      end

      it_behaves_like 'fully authorized user for TestResult'

      it 'scopes to teacher test results' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.all)
      end
    end

    context 'when not teacher of test results student class' do
      it_behaves_like 'unauthorized user'

      it 'scopes to nothing' do
        expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
      end
    end
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, TestResult)).to eq(TestResult.none)
    end
  end
end
