# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolManagerPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { create(:user, :school_manager) }

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
    context 'when SM in own org' do
      let(:user) { build(:user, :org_admin, organisation: record.organisation) }

      it_behaves_like 'fully authorized user'
    end

    context 'when SM in other org' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    context 'when accessing self' do
      let(:user) { record }

      it_behaves_like 'authorized user for editing'
    end

    context 'when accessing other school manager' do
      let(:user) { build(:user, :school_manager) }

      it_behaves_like 'unauthorized user'
    end
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
