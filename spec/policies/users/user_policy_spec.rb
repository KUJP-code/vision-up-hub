# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'authorized KU staff for UserPolicy scope' do
  it 'scopes to all orgs' do
    expect(Pundit.policy_scope!(user, User)).to eq(User.all)
  end
end

RSpec.shared_examples 'OrgAdmin for UserPolicy scope' do
  it 'scopes to all organisation users' do
    org_users = user.organisation.users
    expect(Pundit.policy_scope!(user, User)).to eq(org_users)
  end
end

RSpec.shared_examples 'SM for UserPolicy scope' do
  it 'scopes to school teachers' do
    expect(Pundit.policy_scope!(user, User)).to eq(user.teachers)
  end
end

RSpec.shared_examples 'unauthorized user for UserPolicy scope' do
  it 'scopes to nothing' do
    expect(Pundit.policy_scope!(user, User)).to eq(User.none)
  end
end

RSpec.describe UserPolicy do
  let(:organisation) { create(:organisation) }
  let(:school) { create(:school, organisation:) }

  before do
    create(:user, :org_admin, organisation:)
    create(:user, :school_manager, organisation:)
    create(:user, :teacher, organisation:)
  end

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    context 'when part of KidsUP' do
      let(:ku) { build(:organisation, name: 'KidsUP') }

      before do
        allow(user).to receive(:organisation).and_return(ku)
      end

      it_behaves_like 'authorized KU staff for UserPolicy scope'
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user for UserPolicy scope'
  end

  context 'when org admin' do
    context 'when admin of org being accessed' do
      let(:user) { organisation.users.create(attributes_for(:user, :org_admin)) }

      it_behaves_like 'OrgAdmin for UserPolicy scope'
    end

    context 'when admin of other org' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'OrgAdmin for UserPolicy scope'
    end
  end

  context 'when sales' do
    let(:user) { create(:user, :sales) }

    it 'can access full scope minus other KU staff categories' do
      create(:user, :writer, organisation: user.organisation)
      scoped_users = Pundit.policy_scope!(user, User)
      non_ku_users = User.where(type: Sales::VISIBLE_TYPES)
      expect(scoped_users).to eq(non_ku_users)
    end
  end

  context 'when school manager' do
    let(:user) { create(:user, :school_manager) }

    before do
      user.schools << school
      user.save
    end

    it_behaves_like 'SM for UserPolicy scope'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user for UserPolicy scope'
  end
end
