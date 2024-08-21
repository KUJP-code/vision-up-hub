# frozen_string_literal: true

RSpec.shared_examples_for 'input attributable' do
  let(:input_type) { described_class.name.underscore.to_sym }

  it 'can be required' do
    field = build(input_type, input_attributes: { required: true })
    expect(field.input_attributes.required).to be true
  end

  it 'can be given a placeholder' do
    field = build(input_type, input_attributes: { placeholder: 'placeholder' })
    expect(field.input_attributes.placeholder).to eq 'placeholder'
  end
end
