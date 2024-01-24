# frozen_string_literal: true

RSpec.shared_examples_for 'linkable' do
  let(:link_hash) do
    { 'Example link' => 'http://example.com',
      'Seasonal' => 'http://example.com/seasonal' }
  end

  it 'saves links as hash, pairs split by line and value split by colon' do
    expect(subject.links).to eq(link_hash)
  end

  it 'strips unnecessary whitespace' do
    subject.update(
      links: "Example link:  http://example.com\n Seasonal:http://example.com/seasonal"
    )
    expect(subject.links).to eq(link_hash)
  end
end
