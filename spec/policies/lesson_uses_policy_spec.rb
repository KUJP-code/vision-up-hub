# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonUsesPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it { is_expected.to authorize_action(:index) }
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it { is_expected.to authorize_action(:index) }
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it { is_expected.not_to authorize_action(:index) }
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it { is_expected.not_to authorize_action(:index) }
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it { is_expected.not_to authorize_action(:index) }
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it { is_expected.not_to authorize_action(:index) }
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it { is_expected.not_to authorize_action(:index) }
  end
end
