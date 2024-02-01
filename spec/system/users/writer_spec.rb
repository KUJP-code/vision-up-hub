# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'creating a Writer' do
  let(:organisation) { create(:organisation, name: 'KidsUP') }

  before do
    sign_in create(:user, :admin, organisation:)
  end

  it 'admin can create a writer' do
    visit organisation_writers_path(organisation)
    click_link 'create_writer'
    expect(page).to have_content 'form'
    within '#writer_form' do
      fill_in 'writer_name', with: 'John'
      fill_in 'writer_email', with: 'xjpjv@example.com'
      click_on 'submit_writer'
    end
    expect(page).to have_content 'John'
  end
end
