# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TutorialCategoryPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:organisation) { create(:organisation) }
  let(:record) do
    create(:tutorial_category).tap do |cat|
      create(:organisation_tutorial_category, organisation:, tutorial_category: cat)
    end
  end

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer, organisation:) }

    it_behaves_like 'authorized user for viewing'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'authorized user'
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin, organisation:) }

    it_behaves_like 'authorized user for viewing'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager, organisation:) }

    it_behaves_like 'authorized user for viewing'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher, organisation:) }

    it_behaves_like 'authorized user for viewing'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent, organisation:) }

    it_behaves_like 'authorized user for viewing'
  end
end
