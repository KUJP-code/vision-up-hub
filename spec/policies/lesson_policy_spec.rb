# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'writer for LessonPolicy' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }

  it 'scopes to all lessons' do
    expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.all)
  end
end

RSpec.shared_examples 'unauthorized user for LessonPolicy' do
  it { is_expected.not_to authorize_action(:index) }
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }

  it 'scopes to nothing' do
    expect(Pundit.policy_scope!(user, Lesson)).to eq(Lesson.none)
  end
end

RSpec.describe LessonPolicy do
  subject(:policy) { described_class.new(user, lesson) }

  let(:lesson) { build(:daily_activity) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    context 'when part of KidsUP' do
      let(:ku) { build(:organisation, name: 'KidsUP') }

      before do
        allow(user).to receive(:organisation).and_return(ku)
      end

      it_behaves_like 'writer for LessonPolicy'
    end

    context 'when external organisation' do
      it_behaves_like 'unauthorized user for LessonPolicy'
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    context 'when part of KidsUP' do
      let(:ku) { build(:organisation, name: 'KidsUP') }

      before do
        allow(user).to receive(:organisation).and_return(ku)
      end

      it_behaves_like 'writer for LessonPolicy'
    end

    context 'when external organisation' do
      it_behaves_like 'unauthorized user for LessonPolicy'
    end
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
