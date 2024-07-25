# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CategoryResourcePolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { build(:category_resource) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all category_resources' do
      record.save
      expect(Pundit.policy_scope!(user, CategoryResource)).to contain_exactly(record)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'authorized user except destroy'

    it 'scopes to all category_resources' do
      record.save
      expect(Pundit.policy_scope!(user, CategoryResource)).to contain_exactly(record)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, CategoryResource)).to eq(CategoryResource.none)
    end
  end

  context 'when org admin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, CategoryResource)).to eq(CategoryResource.none)
    end
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, CategoryResource)).to eq(CategoryResource.none)
    end
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      expect(Pundit.policy_scope!(user, CategoryResource)).to eq(CategoryResource.none)
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    # scope is reliant on teacher.category_resources,
    # which is tested as part of the Teacher model
  end
end
