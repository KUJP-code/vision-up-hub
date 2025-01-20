# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  context 'when setting theme from organisation' do
    let(:user) { build(:user, :org_admin) }

    it "returns 'base' if not in list of themed orgs" do
      user.organisation_id = 999
      expect(org_theme(user)).to eq('base')
    end
  end

  context 'when setting favicon/logo from organisation' do
    let(:user) { build(:user, :org_admin, organisation_id: 9) }

    it "returns a path including 'org_n.svg'" do
      expect(org_favicon(user)).to eq('/images/org_1_vision.svg')
    end

    it "returns path including 'org_1.svg' if not in list of themed orgs" do
      user.organisation_id = 999
      expect(org_favicon(user)).to eq('/images/org_1_vision.svg')
    end
  end
end
