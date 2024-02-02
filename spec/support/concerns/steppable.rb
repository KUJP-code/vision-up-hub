# frozen_string_literal: true

RSpec.shared_examples_for 'steppable' do
  it 'saves steps as an array split on new lines' do
    expect(daily_activity.steps).to eq(['Step 1', 'Step 2'])
  end
end
