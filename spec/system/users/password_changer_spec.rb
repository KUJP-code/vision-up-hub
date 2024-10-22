# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Change passwords for users', :js do
  let(:admin) { create(:user, :admin) }
  let(:email) { 'testemail@gmail.com' }
  let(:password) { 'testpassword' }

  before do
    sign_in admin
  end

  it 'allows an admin to change another users password' do
    create(:user, :teacher, email:)

    visit admin_password_change_path
    fill_in 'email', with: email
    fill_in 'new_password', with: password
    fill_in 'confirm_new_password', with: password
    click_on 'commit'
    expect(page).to have_content('Password successfully changed')
  end
end
