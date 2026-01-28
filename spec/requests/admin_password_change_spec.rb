# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin password change', type: :request do
  let(:new_password) { 'newpassword12' }
  let(:ku_organisation) { create(:organisation, name: 'KidsUP') }

  def change_password_for(target)
    post admin_change_password_path,
         params: { email: target.email,
                   new_password:,
                   confirm_new_password: new_password }
  end

  context 'when super admin' do
    let(:admin) { create(:user, :admin, id: 3, organisation: ku_organisation) }
    let(:target) { create(:user, :teacher) }

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
  end

  context 'when admin' do
    let(:admin) { create(:user, :admin, organisation: ku_organisation) }
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
  end
end
