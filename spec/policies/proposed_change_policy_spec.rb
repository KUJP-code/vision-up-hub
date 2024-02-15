# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Admin for ProposedChangePolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

RSpec.describe ProposedChangePolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:proposed_change) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'Admin for ProposedChangePolicy'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    context 'when proponent' do
      before do
        record.proponent_id = user.id
      end

      it { is_expected.not_to authorize_action(:index) }
      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:destroy) }
    end

    context 'when not proponent' do
      it { is_expected.not_to authorize_action(:index) }
      it { is_expected.not_to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:destroy) }
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'
  end
end
