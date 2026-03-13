# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin password change', type: :request do
  let(:new_password) { 'Newpassword12' }
  let(:ku_organisation) { create(:organisation, name: 'KidsUP') }

  def change_password_for(target)
    post admin_change_password_path,
         params: { email: target.email,
                   new_password:,
                   confirm_new_password: new_password }
  end

  def batch_change_password_for(target_group, password: new_password)
    post admin_change_password_path,
         params: { target_group:,
                   new_password: password,
                   confirm_new_password: password }
  end

  context 'when super admin' do
    let(:admin) { create(:user, :admin, id: 3, organisation: ku_organisation) }
    let(:target) { create(:user, :teacher, id: 1000) }

    before do
      sign_in admin
    end

    after do
      sign_out admin
    end

    it 'can change any user password' do
      change_password_for(target)

      expect(flash[:notice]).to eq('Password successfully changed')
    end

    it 'finds a user by email case-insensitively' do
      post admin_change_password_path,
           params: { email: target.email.upcase,
                     new_password:,
                     confirm_new_password: new_password }

      expect(flash[:notice]).to eq('Password successfully changed')
    end

    it 'rejects a password without an uppercase letter' do
      post admin_change_password_path,
           params: { email: target.email,
                     new_password: 'newpassword12',
                     confirm_new_password: 'newpassword12' }

      expect(flash[:alert]).to include(
        'must include at least one uppercase letter, one lowercase letter, and one number'
      )
    end

    it 'can batch change KidsUP teacher passwords' do
      target_one = create(:user, :teacher, id: 1001, organisation: ku_organisation, password: 'Oldpassword1')
      target_two = create(:user, :teacher, id: 1002, organisation: ku_organisation, password: 'Oldpassword1')
      other_org_teacher = create(:user, :teacher, id: 1003, password: 'Oldpassword1')

      batch_change_password_for('ku_teachers')

      expect(flash[:notice]).to eq('2 KidsUP teacher password(s) successfully changed')
      expect(target_one.reload.valid_password?(new_password)).to be true
      expect(target_two.reload.valid_password?(new_password)).to be true
      expect(other_org_teacher.reload.valid_password?(new_password)).to be false
    end

    it 'can batch change KidsUP manager passwords' do
      target = create(:user, :school_manager, id: 1011, organisation: ku_organisation, password: 'Oldpassword1')
      other_role = create(:user, :teacher, id: 1012, organisation: ku_organisation, password: 'Oldpassword1')

      batch_change_password_for('ku_managers')

      expect(flash[:notice]).to eq('1 KidsUP manager password(s) successfully changed')
      expect(target.reload.valid_password?(new_password)).to be true
      expect(other_role.reload.valid_password?(new_password)).to be false
    end
  end

  context 'when admin' do
    let(:admin) { create(:user, :admin, id: 101, organisation: ku_organisation) }
    let(:super_admin) { create(:user, :admin, id: 3, organisation: ku_organisation) }

    before do
      sign_in admin
    end

    after do
      sign_out admin
    end

    it 'cannot change another admin password' do
      target = create(:user, :admin, organisation: ku_organisation)

      change_password_for(target)

      expect(flash[:alert]).to eq('Not authorized to change this password')
    end

    it 'can change a teacher password' do
      target = create(:user, :teacher)

      change_password_for(target)

      expect(flash[:notice]).to eq('Password successfully changed')
    end

    it 'cannot change a super admin password' do
      target = super_admin

      change_password_for(target)

      expect(flash[:alert]).to eq('Not authorized to change this password')
    end
  end

  context 'when org admin' do
    let(:organisation) { create(:organisation) }
    let(:admin) { create(:user, :org_admin, organisation:) }

    before do
      sign_in admin
    end

    after do
      sign_out admin
    end

    it 'can change a user password in the same organisation' do
      target = create(:user, :teacher, organisation:)

      change_password_for(target)

      expect(flash[:notice]).to eq('Password successfully changed')
    end

    it 'cannot change a user password in a different organisation' do
      target = create(:user, :teacher)

      change_password_for(target)

      expect(flash[:alert]).to eq('Not authorized to change this password')
    end

    it 'cannot batch change KidsUP staff passwords' do
      batch_change_password_for('ku_teachers')

      expect(flash[:alert]).to eq('Not authorized to batch change these passwords')
    end
  end
end
