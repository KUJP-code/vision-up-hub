# frozen_string_literal: true

RSpec.shared_examples_for 'steppable' do
  it 'saves steps as an array split on new lines' do
    expect(daily_activity.steps).to eq(['Step 1', 'Step 2'])
  end

  it 'always returns an array even if only one step is passed' do
    one_step = build(:daily_activity, steps: 'Step 1')
    one_step.save
    expect(one_step.steps).to eq(['Step 1'])
  end
end
