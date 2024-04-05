# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  context 'when setting theme from organisation' do
    let(:user) { build(:user, :org_admin, organisation_id: 2) }

    it 'returns a string in the form org_n' do
      expect(org_theme(user)).to eq('org_2')
    end

    it "returns 'base' if not in list of themed orgs" do
      user.organisation_id = 999 # congrats if this breaks
      expect(org_theme(user)).to eq('base')
    end
  end
end
