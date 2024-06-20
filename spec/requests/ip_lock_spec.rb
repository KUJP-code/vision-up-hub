# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'School IP Lock' do
  let(:school) { create(:school, ip: '89.207.132.170') }
  let(:non_school_ip) { '127.0.0.1' }
  let(:kids_up) { create(:organisation, name: 'KidsUP') }

  before do
    user.schools << school
    sign_in user
  end

  after do
    sign_out user
  end

  context 'when KidsUP Teacher' do
    let(:user) { create(:user, :teacher, organisation: kids_up) }

    it 'allows access if in school' do
      get students_path, env: { 'REMOTE_ADDR' => school.ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows external access if only school has wildcard IP (*)' do
      school.update(ip: '*')
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows external access if wildcard is part of allowed IPs' do
      wildcard_school = create(:school, ip: '*')
      user.schools << wildcard_school
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'redirects to root if not in school' do
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to redirect_to(root_path)
    end

    it 'displays alert if not in school' do
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end

    it 'denies access if school has no IP' do
      school.update(ip: nil)
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end
  end

  context 'when external Teacher' do
    let(:user) { create(:user, :teacher) }

    it 'allows access if in school' do
      get students_path, env: { 'REMOTE_ADDR' => school.ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows access if outside school' do
      get students_path, env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end
  end

  context 'when KidsUP SM' do
    let(:user) { create(:user, :school_manager, organisation: kids_up) }

    it 'allows access if in school' do
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => school.ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows external access if only school has wildcard IP (*)' do
      school.update(ip: '*')
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows external access if wildcard is part of allowed IPs' do
      user.schools << create(:school, ip: '*')
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end

    it 'redirects to root if not in school' do
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to redirect_to(root_path)
    end

    it 'displays alert if not in school' do
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end

    it 'denies access if school has no IP' do
      school.update(ip: nil)
      get organisation_school_manager_path(kids_up, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(flash[:alert]).to eq(I18n.t('not_in_school'))
    end
  end

  context 'when external SM' do
    let(:user) { create(:user, :school_manager) }

    it 'allows access if in school' do
      get organisation_school_manager_path(user.organisation, user),
          env: { 'REMOTE_ADDR' => school.ip }
      expect(response).to have_http_status(:success)
    end

    it 'allows access if outside school' do
      get organisation_school_manager_path(user.organisation, user),
          env: { 'REMOTE_ADDR' => non_school_ip }
      expect(response).to have_http_status(:success)
    end
  end
end
