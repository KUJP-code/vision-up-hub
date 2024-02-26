# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'manager of different school for SchoolClassPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.describe SchoolClassPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:school_class) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'

    it 'scopes to all classes' do
      expect(Pundit.policy_scope!(user, SchoolClass)).to eq(SchoolClass.all)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to no classes' do
      expect(Pundit.policy_scope!(user, SchoolClass)).to eq(SchoolClass.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to no classes' do
      expect(Pundit.policy_scope!(user, SchoolClass)).to eq(SchoolClass.none)
    end
  end

  context 'when org admin' do
    context 'when admin of class org' do
      let(:user) { build(:user, :org_admin, organisation_id: record.organisation_id) }

      it_behaves_like 'fully authorized user'

      it 'scopes to all org classes' do
        org_classes = user.organisation.classes
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq(org_classes)
      end
    end

    context 'when admin of different org' do
      let(:user) { build(:user, :org_admin) }

      it { is_expected.to authorize_action(:index) }
      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to own org classes' do
        org_classes = user.organisation.classes
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq(org_classes)
      end
    end
  end

  context 'when school manager' do
    context 'when manager of class school' do
      let(:user) { create(:user, :school_manager, organisation_id: record.organisation_id) }

      before do
        user.schools << record.school
      end

      it_behaves_like 'fully authorized user'

      it 'scopes to all managed classes' do
        managed_classes = user.schools.first.classes
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq(managed_classes)
      end
    end

    context 'when manager of different school in same org' do
      let(:user) { build(:user, :school_manager, organisation_id: record.organisation_id) }

      it_behaves_like 'manager of different school for SchoolClassPolicy'

      it 'scopes to own school classes' do
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq([])
      end
    end

    context 'when school manager at different org' do
      let(:user) { build(:user, :school_manager) }

      it_behaves_like 'manager of different school for SchoolClassPolicy'

      it 'scopes to own school classes' do
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq([])
      end
    end
  end

  context 'when teacher' do
    context 'when teacher of class' do
      let(:user) { build(:user, :teacher, organisation_id: record.organisation_id) }

      before do
        user.classes << record
      end

      it { is_expected.to authorize_action(:index) }
      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to their own classes' do
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq([record])
      end
    end

    context 'when teacher of different class' do
      let(:user) { build(:user, :teacher, organisation_id: record.organisation_id) }

      it { is_expected.to authorize_action(:index) }
      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to their own classes' do
        expect(Pundit.policy_scope!(user, SchoolClass)).to eq([])
      end
    end
  end
end
