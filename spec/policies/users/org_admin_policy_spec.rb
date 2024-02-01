# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgAdminPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:user, :org_admin) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'fully authorized user'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when org admin' do
    context 'when accessing self' do
      let(:user) { record }

      it_behaves_like 'authorized user for editing'
    end

    context 'when accessing other admin of same org' do
      let(:user) { build(:user, :org_admin, organisation: record.organisation) }

      it_behaves_like 'authorized user for viewing'
    end

    context 'when accessing other org admin' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'unauthorized user'
    end
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
