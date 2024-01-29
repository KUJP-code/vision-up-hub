# frozen_string_literal: true

RSpec.shared_examples 'writer for LessonPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
end

RSpec.shared_examples 'unauthorized user for LessonPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
end

RSpec.describe LessonPolicy do
  subject(:policy) { described_class.new(user, lesson) }

  let(:lesson) { build(:daily_activity) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'writer for LessonPolicy'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'writer for LessonPolicy'
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user for LessonPolicy'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user for LessonPolicy'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user for LessonPolicy'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user for LessonPolicy'
  end
end
