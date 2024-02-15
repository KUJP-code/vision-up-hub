# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Listable do
  subject(:daily_activity) { build(:daily_activity) }

  it 'saves instructions as an array split on new lines' do
    daily_activity.instructions = "Step 1\nStep 2"
    daily_activity.save
    expect(daily_activity.instructions).to eq(['Step 1', 'Step 2'])
  end

  it 'always returns an array even if only one step is passed' do
    daily_activity.instructions = 'Step 1'
    daily_activity.save
    expect(daily_activity.instructions).to eq(['Step 1'])
  end

  it 'returns the current value of the field if unchanged' do
    daily_activity.save
    old_instructions = daily_activity.instructions
    daily_activity.update(title: 'New Title')
    expect(daily_activity.instructions).to eq(old_instructions)
  end
end
