# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParentPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:user, :parent) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user except destroy'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'
  end

  context 'when org admin' do
    context 'when admin of parent org' do
      let(:user) { build(:user, :org_admin, organisation: record.organisation) }

      it_behaves_like 'authorized user except destroy'
    end

    context 'when admin of different org' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'authorized user except destroy'
    end
  end

  context 'when school manager' do
    context 'when manager of parent school' do
      let(:school) { create(:school) }
      let(:user) { create(:user, :school_manager, schools: [school]) }

      before do
        record.children << create(:student, school:)
        record.update(organisation_id: user.organisation_id)
      end

      it_behaves_like 'authorized user'
    end

    context 'when manager of different school' do
      let(:user) { build(:user, :school_manager) }

      it_behaves_like 'unauthorized user except new'
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'
  end

  context 'when parent' do
    context 'when viewing self' do
      let(:user) { record }

      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:destroy) }
    end

    context 'when viewing another parent' do
      let(:user) { create(:user, :parent) }

      it_behaves_like 'unauthorized user'
    end
  end
end
