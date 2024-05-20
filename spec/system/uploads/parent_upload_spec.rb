# frozen_string_literal: true

require 'rails_helper'
require 'csv'

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
    expect(page).to have_css('.error', count: 1)
    expect(page).to have_css('.uploaded', count: 2)
    expect(Parent.count).to eq(2)
    within '#parent-row-2' do
      fill_in 'parent_upload[name]', with: 'Jane Doe'
      fill_in 'parent_upload[email]', with: 'jane@doe.com'
      fill_in 'parent_upload[password]', with: 'testpassword'
      fill_in 'parent_upload[password_confirmation]', with: 'testpassword'
      click_button 'Create User'
    end
    expect(page).to have_css('.uploaded', count: 3)
    expect(Parent.count).to eq(3)
  end
end

def create_parents_csv
  parents = create_parents
  CSV.open('tmp/parents.csv', 'w') do |csv|
    csv << %w[name email password password_confirmation]
    parents.each do |parent|
      csv << parent
    end
  end
end

def create_parents
  parents = build_list(:user, 2, :parent,
                       password: 'testpassword',
                       password_confirmation: 'testpassword')
  invalid_parent = build(:user, :parent, email: '')
  parents << invalid_parent
  parents.map { |p| [p.name, p.email, p.password, p.password] }
end
