# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnouncementPolicy do
  subject(:announcement) { described_class.new(user, record) }

  let(:record) { build(:announcement) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all announcements' do
      record.save
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(record)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation), role: 'Sales') # unseen
      create(:announcement, finish_date: 2.days.ago) # unseen
      role_announcement = create(:announcement, role: 'Writer', message: 'Writer announcement')
      org = create(:organisation, name: 'KidsUP')
      user.save
      user.update(organisation_id: org.id)
      org_announcement = create(:announcement, message: 'Org Announcement', organisation: user.organisation)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(role_announcement, org_announcement)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation), role: 'Writer') # unseen
      create(:announcement, finish_date: 2.days.ago) # unseen
      role_announcement = create(:announcement, role: 'Sales')
      org = create(:organisation, name: 'KidsUP')
      user.save
      user.update(organisation_id: org.id)
      org_announcement = create(:announcement, organisation: user.organisation)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(role_announcement, org_announcement)
    end
  end

  context 'when org_admin' do
    let(:user) { create(:user, :org_admin) }

    context 'when different org_admin' do
      it_behaves_like 'unauthorized user'
    end

    context 'when same org_admin' do
      before do
        record.save
        record.update(organisation_id: user.organisation_id)
      end

      it_behaves_like 'authorized user'
    end

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation)) # unseen
      org_announcement = create(:announcement, organisation: user.organisation)
      generic_announcement = create(:announcement)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(generic_announcement, org_announcement)
    end
  end

  context 'when SchoolManager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation), role: 'Sales') # unseen
      create(:announcement, finish_date: 2.days.ago) # unseen
      role_announcement = create(:announcement, role: 'SchoolManager', message: 'School Manager announcement')
      org = create(:organisation)
      user.save
      user.update(organisation_id: org.id)
      org_announcement = create(:announcement, message: 'Org Announcement', organisation: user.organisation)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(role_announcement, org_announcement)
    end
  end

  context 'when Teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation), role: 'Sales') # unseen
      create(:announcement, finish_date: 2.days.ago) # unseen
      role_announcement = create(:announcement, role: 'Teacher', message: 'Teacher announcement')
      org = create(:organisation)
      user.save
      user.update(organisation_id: org.id)
      org_announcement = create(:announcement, message: 'Org Announcement', organisation: user.organisation)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(role_announcement, org_announcement)
    end
  end

  context 'when Parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to targetted announcements' do
      create(:announcement, organisation: create(:organisation), role: 'Sales') # unseen
      create(:announcement, finish_date: 2.days.ago) # unseen
      role_announcement = create(:announcement, role: 'Parent', message: 'Parent announcement')
      org = create(:organisation)
      user.save
      user.update(organisation_id: org.id)
      org_announcement = create(:announcement, message: 'Org Announcement', organisation: user.organisation)
      expect(Pundit.policy_scope!(user, Announcement)).to contain_exactly(role_announcement, org_announcement)
    end
  end
end
