# frozen_string_literal: true

RSpec.shared_examples_for 'steppable' do
  it 'saves steps as an array split on new lines' do
    subject.update(steps: "Step 1\nStep 2")
    expect(subject.steps).to eq(['Step 1', 'Step 2'])
  end

  it 'always returns an array even if only one step is passed' do
    subject.update(steps: 'Step 1')
    expect(subject.steps).to eq(['Step 1'])
  end

  it 'returns the current value of the field if unchanged' do
    old_steps = subject.steps
    subject.update(title: 'New Title')
    expect(subject.steps).to eq(old_steps)
  end
end
