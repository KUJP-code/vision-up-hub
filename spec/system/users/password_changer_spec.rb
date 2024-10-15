# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Change passwords for users'
let(:admin) { create(:user, :admin) }
let(:user) { create(:user, :teacher) }

before do
  sign_in admin
end

it 'allows an admin to change another users password' do
  visit password_change_path
  fill_in 'users email'
  fill_in 'new password', with: 'testpassword'
  fill_in 'confirm new password', with: 'testpassword'
  click_on 'commit'

  expect(page).to have_content I18n.t('success')
end
