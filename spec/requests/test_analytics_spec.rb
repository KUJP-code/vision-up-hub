# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Test analytics' do
  let(:admin) { create(:user, :admin) }
  let(:organisation) { admin.organisation }

  describe 'GET /tests/analytics' do
    it 'renders the analytics dashboard for admins' do
      sign_in admin

      get analytics_tests_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Analytics', 'All schools overview', 'Last year', 'Last 5 years')
    end

    it 'lists the newest tests first and includes their levels' do
      older = create(:test, name: 'July 2025', level: :land_one, created_at: 1.year.ago)
      newer = create(:test, name: 'July 2026', level: :sky_one, created_at: 1.day.ago)
      sign_in admin

      get analytics_tests_path

      expect(response.body.index("#{newer.name} (Sky)"))
        .to be < response.body.index("#{older.name} (Land)")
    end

    it 'falls back to the latest test month when the last three months are empty' do
      school = create(:school, organisation:)
      student = create(:student, organisation:, school:)
      test = create(:test)
      tested_on = 4.months.ago.to_date
      create(:test_result, student:, test:, tested_on:, reason: 'Seeded result')
      sign_in admin

      get analytics_tests_path(test_id: test.id)

      expect(response.body).to include("Latest test set · #{tested_on.strftime('%B %Y')}")
      expect(response.body).not_to include('Last year', 'Last 5 years')
      expect(response.body).not_to include('Last 6 months')
    end

    it 'does not allow teachers to view analytics' do
      teacher = create(:user, :teacher, organisation:)
      sign_in teacher

      get analytics_tests_path

      expect(response).to redirect_to(authenticated_root_path)
    end
  end

  describe 'GET /tests/analytics/export' do
    it 'exports an analytics table as CSV' do
      sign_in admin
      test = create(:test)

      get analytics_export_tests_path(table: 'schools', test_id: test.id)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq('text/csv')
      expect(response.body).to start_with('name,organisation,students')
    end
  end
end
