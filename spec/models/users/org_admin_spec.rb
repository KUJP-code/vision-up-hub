# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrgAdmin do
  it 'has a valid factory' do
    expect(build(:user, :org_admin)).to be_valid
  end
end
