# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Management do
  it 'is valid when the school manager belongs to the same organisation as the school' do
    school = create(:school)
    school_manager = create(:user, :school_manager, organisation: school.organisation)

    expect(described_class.new(school:, school_manager:)).to be_valid
  end

  it 'is invalid when the school belongs to a different organisation than the school manager' do
    school_manager = create(:user, :school_manager)
    other_school = create(:school)

    management = described_class.new(school: other_school, school_manager:)

    expect(management).not_to be_valid
    expect(management.errors[:school]).to include(
      'must belong to the same organisation as the school manager'
    )
  end
end
