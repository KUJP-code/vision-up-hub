# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a seasonal activit' do
  let!(:org) { create(:organisation, name: 'KidsUP') }

  before do
    user = org.users.create(attributes_for(:user, :writer))
    sign_in user
  end

  it 'can create a Seasonal activity' do
    visit lessons_path
    find_by_id('create_lesson').click
    click_link 'create_seasonal_activity'
    within '#seasonal_activity_form' do
      fill_in 'seasonal_activity_title', with: 'Test Seasonal Activity'
    end
  end
end
