# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing AI Sensei event accounts' do
  let(:admin) { create(:user, :admin) }
  let(:organisation) { admin.organisation }
  let(:account) { create(:user, :ai_sensei, organisation:) }

  before { sign_in admin }

  it 'offers event accounts in the admin user menu and role search' do
    get users_path

    expect(response.body).to include('create_ai_sensei')
    expect(response.body).to include('ai-sensei')
    get new_organisation_ai_sensei_path(organisation)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('ai_sensei_form')
  end

  it 'lets admins create and update an event account' do
    expect do
      post organisation_ai_senseis_path(organisation),
           params: { ai_sensei: { name: 'Event Demo', email: 'event@example.com',
                                  password: 'Password123', password_confirmation: 'Password123',
                                  organisation_id: organisation.id } }
    end.to change(AiSensei, :count).by(1)

    created = AiSensei.find_by!(email: 'event@example.com')
    expect(response).to redirect_to(edit_organisation_ai_sensei_path(organisation, created))
    patch organisation_ai_sensei_path(organisation, created), params: { ai_sensei: { name: 'Updated Event' } }
    expect(created.reload.name).to eq('Updated Event')
    get edit_organisation_ai_sensei_path(organisation, created)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Delete')
  end

  it 'keeps invalid accounts on the form with validation errors' do
    post organisation_ai_senseis_path(organisation),
         params: { ai_sensei: { name: '', email: 'invalid', password: 'weak', organisation_id: organisation.id } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('ai_sensei_form')
  end

  it 'lets admins delete event accounts without deleting other users' do
    account
    expect do
      delete organisation_ai_sensei_path(organisation, account)
    end.to change(AiSensei, :count).by(-1)
    expect(response).to redirect_to(users_path)
    expect(Admin.exists?(admin.id)).to be true
  end

  it 'cannot use an event account route to change another account type' do
    patch organisation_ai_sensei_path(organisation, admin), params: { ai_sensei: { name: 'Changed' } }

    expect(response).to have_http_status(:not_found)
    expect(admin.reload.name).not_to eq('Changed')
  end

  it 'does not permit other roles to create or delete event accounts' do
    sign_out admin
    sign_in create(:user, :org_admin, organisation:)

    expect do
      post organisation_ai_senseis_path(organisation),
           params: { ai_sensei: { name: 'Unauthorized', email: 'unauthorized@example.com',
                                  password: 'Password123', organisation_id: organisation.id } }
    end.not_to change(AiSensei, :count)
    expect(response).to redirect_to(root_path)

    existing = account
    expect { delete organisation_ai_sensei_path(organisation, existing) }.not_to change(AiSensei, :count)
    expect(response).to redirect_to(root_path)
  end
end
