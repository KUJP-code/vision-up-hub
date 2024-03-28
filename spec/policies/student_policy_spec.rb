# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'student creator for StudentPolicy' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.describe StudentPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:student) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'

    it 'scopes to all students' do
      expect(Pundit.policy_scope!(user, Student)).to eq(Student.all)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to no students' do
      expect(Pundit.policy_scope!(user, Student)).to eq(Student.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to no students' do
      expect(Pundit.policy_scope!(user, Student)).to eq(Student.none)
    end
  end

  context 'when org admin' do
    context 'when admin of student org' do
      let(:user) { build(:user, :org_admin, organisation_id: record.organisation_id) }

      it_behaves_like 'fully authorized user'

      it 'scopes to all org students' do
        org_students = user.organisation.schools.map(&:students).flatten
        expect(Pundit.policy_scope!(user, Student)).to eq(org_students)
      end
    end

    context 'when admin of different org' do
      let(:user) { build(:user, :org_admin) }

      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to all org students' do
        expect(Pundit.policy_scope!(user, Student)).to eq([])
      end
    end
  end

  context 'when school manager' do
    context 'when manager of student school' do
      let(:user) { create(:user, :school_manager, organisation_id: record.organisation_id) }

      before do
        user.schools << record.school
      end

      it_behaves_like 'fully authorized user'

      it 'scopes to all students of managed schools' do
        expect(Pundit.policy_scope!(user, Student)).to eq(user.students)
      end
    end

    context 'when manager of different school' do
      let(:user) { build(:user, :school_manager) }

      it_behaves_like 'student creator for StudentPolicy'

      it 'scopes to all students of managed schools' do
        expect(Pundit.policy_scope!(user, Student)).to eq([])
      end
    end
  end

  context 'when teacher' do
    context 'when teaching student class' do
      let(:user) { create(:user, :teacher, organisation_id: record.organisation_id) }
      let(:student_class) { create(:school_class) }

      before do
        record.classes << student_class
        user.classes << record.classes.first
      end

      it { is_expected.to authorize_action(:show) }
      it { is_expected.to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to taught students' do
        expect(Pundit.policy_scope!(user, Student)).to eq(user.students)
      end
    end

    context 'when not teaching student class' do
      let(:user) { build(:user, :teacher) }

      it_behaves_like 'student creator for StudentPolicy'

      it 'scopes to taught students' do
        expect(Pundit.policy_scope!(user, Student)).to eq([])
      end
    end
  end

  context 'when parent' do
    context 'when parent of student' do
      let(:user) { create(:user, :parent) }

      before do
        user.children << record
      end

      it_behaves_like 'authorized user except destroy'
    end

    context 'when parent of different student' do
      let(:user) { build(:user, :parent) }

      it_behaves_like 'unauthorized user except new'
    end
  end
end
