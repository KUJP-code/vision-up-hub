# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Listable do
  subject(:daily_activity) { build(:daily_activity) }

  it 'saves steps as an array split on new lines' do
    daily_activity.steps = "Step 1\nStep 2"
    daily_activity.save
    expect(daily_activity.steps).to eq(['Step 1', 'Step 2'])
  end

  it 'always returns an array even if only one step is passed' do
    daily_activity.steps = 'Step 1'
    daily_activity.save
    expect(daily_activity.steps).to eq(['Step 1'])
  end

  it 'returns the current value of the field if unchanged' do
    daily_activity.save
    old_steps = daily_activity.steps
    daily_activity.update(title: 'New Title')
    expect(daily_activity.steps).to eq(old_steps)
  end
end
