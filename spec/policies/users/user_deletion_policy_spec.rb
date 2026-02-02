# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User deletion permissions' do
  let(:organisation) { create(:organisation) }
  let(:admin) { build(:user, :admin) }
  let(:super_admin) { build(:user, :admin, id: AdminPolicy::SPECIAL_ADMIN_IDS.first) }

  let(:other_admin) { create(:user, :admin, organisation:) }
  let(:writer) { create(:user, :writer, organisation:) }
  let(:school_manager) { create(:user, :school_manager, organisation:) }
  let(:org_admin) { create(:user, :org_admin, organisation:) }
  let(:teacher) { create(:user, :teacher, organisation:) }
  let(:parent) { create(:user, :parent, organisation:) }

  it 'allows super admins to delete admins' do
    expect(AdminPolicy.new(super_admin, other_admin)).to authorize_action(:destroy)
  end

  it 'allows admins to delete teachers, org admins, school managers, and writers' do
    expect(TeacherPolicy.new(admin, teacher)).to authorize_action(:destroy)
    expect(OrgAdminPolicy.new(admin, org_admin)).to authorize_action(:destroy)
    expect(SchoolManagerPolicy.new(admin, school_manager)).to authorize_action(:destroy)
    expect(WriterPolicy.new(admin, writer)).to authorize_action(:destroy)
  end

  it 'allows org admins and school managers to delete teachers in their scope' do
    school = create(:school, organisation:)
    teacher.schools << school
    scoped_org_admin = build(:user, :org_admin, organisation:)
    scoped_school_manager = build(:user, :school_manager, organisation:, schools: [school])

    expect(TeacherPolicy.new(scoped_org_admin, teacher)).to authorize_action(:destroy)
    expect(TeacherPolicy.new(scoped_school_manager, teacher)).to authorize_action(:destroy)
  end

  it 'prevents non-admins from deleting users' do
    non_admin = build(:user, :writer, organisation:)

    expect(TeacherPolicy.new(non_admin, teacher)).not_to authorize_action(:destroy)
    expect(OrgAdminPolicy.new(non_admin, org_admin)).not_to authorize_action(:destroy)
    expect(SchoolManagerPolicy.new(non_admin, school_manager)).not_to authorize_action(:destroy)
    expect(WriterPolicy.new(non_admin, writer)).not_to authorize_action(:destroy)
    expect(ParentPolicy.new(non_admin, parent)).not_to authorize_action(:destroy)
  end
end
