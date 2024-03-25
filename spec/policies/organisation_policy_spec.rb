# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'KU staff for OrganisationPolicy' do
  it_behaves_like 'authorized user except destroy'

  it 'scopes to all orgs' do
    expect(Pundit.policy_scope!(user, Organisation)).to eq(Organisation.all)
  end
end

RSpec.shared_examples 'unauthorized user for OrganisationPolicy' do
  it_behaves_like 'unauthorized user'

  it 'scopes to nothing' do
    expect(Pundit.policy_scope!(user, Organisation)).to eq(Organisation.none)
  end
end

RSpec.describe OrganisationPolicy do
  subject(:policy) { described_class.new(user, org) }

  let(:org) { build(:organisation) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'KU staff for OrganisationPolicy'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user for OrganisationPolicy'
  end

  context 'when org admin' do
    before do
      org.save
    end

    context 'when admin of org being accessed' do
      let(:user) { org.users.create(attributes_for(:user, :org_admin)) }

      it { is_expected.not_to authorize_action(:index) }
      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }

      it 'scopes to nothing' do
        expect(Pundit.policy_scope!(user, Organisation)).to eq(Organisation.none)
      end
    end

    context 'when admin of other org' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'unauthorized user for OrganisationPolicy'
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'KU staff for OrganisationPolicy'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user for OrganisationPolicy'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user for OrganisationPolicy'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user for OrganisationPolicy'
  end
end
