# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'notification receiver' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

RSpec.describe NotificationPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { Notification.new }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.to authorize_action(:new) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:update) }
    it { is_expected.to authorize_action(:destroy) }
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'notification receiver'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'notification receiver'
  end

  context 'when OrgAdmin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'notification receiver'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'notification receiver'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'notification receiver'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'notification receiver'
  end
end
