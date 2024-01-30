# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating an organisation' do
  before do
    sign_in create(:user, :sales)
  end

  it 'can create an organisation' do
    visit organisations_path
    click_link I18n.t('organisations.index.add_organisation')
    visit new_organisation_path
    fill_in 'organisation_name', with: 'Test Organisation'
    click_button 'Create Organisation'
    expect(page).to have_content('Test Organisation')
  end
end
