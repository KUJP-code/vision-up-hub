# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdminPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:user, :admin) }

  context 'when admin' do
    context 'when touching self' do
      let(:user) { record }

      it { is_expected.not_to authorize_action(:index) }
      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.to authorize_action(:reassign_editor) }
    end

    context 'when interacting with other admin' do
      let(:user) { build(:user, :admin) }

      it { is_expected.not_to authorize_action(:index) }
      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:update) }
      it { is_expected.to authorize_action(:reassign_editor) }
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:reassign_editor) }
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:reassign_editor) }
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:reassign_editor) }
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:reassign_editor) }
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'
    it { is_expected.not_to authorize_action(:reassign_editor) }
  end
end
