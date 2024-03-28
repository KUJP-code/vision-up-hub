# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'authorized KU staff for UserPolicy scope' do
  it 'scopes to all orgs' do
    expect(Pundit.policy_scope!(user, User)).to eq(User.all)
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
    student = create(:student)
    create(:user, :parent, organisation:, children: [student])
    create(:user, :parent, organisation:)
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

      it 'scopes to all org users' do
        expect(Pundit.policy_scope!(user, User)).to eq(organisation.users)
      end
    end

    context 'when admin of other org' do
      let(:user) { build(:user, :org_admin) }

      it 'scopes to all users in their org' do
        expect(Pundit.policy_scope!(user, User)).to eq(user.organisation.users)
      end
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
    let(:user) { create(:user, :school_manager, organisation:) }

    before do
      user.schools << school
      Teacher.find_each { |t| t.schools << school }
      Student.find_each { |s| s.update(school_id: user.schools.first.id) }
      user.save
    end

    context 'when part of childless parent org' do
      it 'scopes to school teachers, parents and childless parents' do
        expect(Pundit.policy_scope!(user, User)).to eq(
          user.teachers + user.parents + Parent.where.missing(:children)
        )
      end
    end

    context 'when part of different org to childless parent' do
      it 'scopes to just school teachers and parents' do
        user.update(organisation: create(:organisation))
        expect(Pundit.policy_scope!(user, User)).to eq(Teacher.all + user.parents)
      end
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user for UserPolicy scope'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user for UserPolicy scope'
  end
end
