# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'user scoped to all schools' do
  it 'returns all schools' do
    expect(Pundit.policy_scope!(user, School)).to eq(School.all)
  end
end

RSpec.shared_examples 'user scoped to no schools' do
  it 'returns no schools' do
    expect(Pundit.policy_scope!(user, School)).to eq(School.none)
  end
end

RSpec.describe SchoolPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:school) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'
    it_behaves_like 'user scoped to all schools'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
    it_behaves_like 'user scoped to no schools'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'fully authorized user'
    it_behaves_like 'user scoped to all schools'
  end

  context 'when org admin' do
    context "when admin of school's org" do
      let(:user) { create(:user, :org_admin, organisation: record.organisation) }

      it_behaves_like 'fully authorized user'

      it 'scopes to all org schools' do
        org_schools = School.where(organisation_id: user.organisation_id)
        expect(Pundit.policy_scope!(user, School)).to eq(org_schools)
      end
    end

    context 'when admin of different org' do
      let(:user) { create(:user, :org_admin) }

      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }

      it 'scopes to all org schools' do
        org_schools = School.where(organisation_id: user.organisation_id)
        expect(Pundit.policy_scope!(user, School)).to eq(org_schools)
      end
    end
  end

  context 'when school manager' do
    context 'when manager of school' do
      let(:user) { create(:user, :school_manager, schools: [record]) }

      it_behaves_like 'authorized user for editing'

      it 'scopes to all managed schools' do
        expect(Pundit.policy_scope!(user, School)).to eq(user.schools)
      end
    end

    context 'when manager of different school' do
      let(:user) { create(:user, :school_manager) }

      it_behaves_like 'unauthorized user'

      it 'scopes to all managed schools' do
        expect(Pundit.policy_scope!(user, School)).to eq(user.schools)
      end
    end
  end

  context 'when teacher' do
    let(:user) { create(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to all schools it teaches at' do
      expect(Pundit.policy_scope!(user, School)).to eq(user.schools)
    end
  end
end
