# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestPolicy do
  subject(:policy) { described_class.new(user, course) }

  let(:course) { build(:course) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'

    it 'scopes to all courses' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.all)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, Test)).to eq(Test.none)
    end
  end
end
