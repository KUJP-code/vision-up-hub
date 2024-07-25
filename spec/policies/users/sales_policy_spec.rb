# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SalesPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:user, :sales) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when sales' do
    context 'when accessing self' do
      let(:user) { record }

      it_behaves_like 'authorized user except destroy'
    end

    context 'when interacting with other sales staff' do
      let(:user) { build(:user, :sales) }

      it { is_expected.to authorize_action(:show) }
      it { is_expected.to authorize_action(:new) }
      it { is_expected.not_to authorize_action(:edit) }
      it { is_expected.to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:update) }
    end
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

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'
  end
end
