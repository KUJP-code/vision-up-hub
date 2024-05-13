# frozen_string_literal: true

require 'rails_helper'
require 'csv'

# TODO: The feature works, but I can't get the test to make a request.
# Request.js never makes a PATCH request to the backend in test
# regardless of how long I wait. So this just tests parsing for now.
RSpec.describe 'creating parent records from a CSV', :js do
  let(:user) { create(:user, :org_admin) }

  before do
    sign_in user
    create_parents_csv
  end

  after do
    File.delete('tmp/parents.csv')
  end

  it 'can parse parents from a CSV' do
    visit new_organisation_parent_upload_path(organisation_id: user.organisation_id)
    within '#parent_create_form' do
      attach_file 'parent_upload_file', Rails.root.join('tmp/parents.csv')
      click_button I18n.t('parent_uploads.new.create_parents', org: user.organisation.name)
    end
    expect(find_by_id('pending_count')).to have_content('3')
    expect(page).to have_css('.border-red-500', count: 1)
    expect(page).to have_css('.border-slate-500', count: 2)
  end
end

def create_parents_csv
  parents = create_parents
  CSV.open('tmp/parents.csv', 'w') do |csv|
    csv << Parent.new.attributes.keys
    parents.each do |parent|
      csv << parent.attributes.values
    end
  end
end

def create_parents
  parents = build_list(:user, 2, :parent)
  invalid_parent = build(:user, :parent, email: '')
  parents << invalid_parent
end
