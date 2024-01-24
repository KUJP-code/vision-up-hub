# frozen_string_literal: true

RSpec.shared_examples_for 'linkable' do
  let(:link_hash) do
    { 'Example link' => 'http://example.com',
      'Seasonal' => 'http://example.com/seasonal' }
  end

  it 'links as hash, pairs split by line and value split by colon' do
    expect(subject.links).to eq(link_hash)
  end

  it 'strips unnecessary whitespace' do
    subject.update(
      links: "Example link:  http://example.com\n Seasonal:http://example.com/seasonal"
    )
    expect(subject.links).to eq(link_hash)
  end

  it 'resolves empty input to empty hash' do
    subject.update(links: '')
    expect(subject.links).to eq({})
  end

  it 'adds link missing error on missing link' do
    subject.update(links: 'Example link:')
    errors = subject.errors.full_messages
    expect(errors).to include('Links missing for Example link')
  end

  it 'adds link missing error on missing link & :' do
    subject.update(links: 'Example link')
    errors = subject.errors.full_messages
    expect(errors).to include('Links missing for Example link')
  end

  it 'adds link text missing error on missing link text' do
    subject.update(links: ': http://example.com')
    errors = subject.errors.full_messages
    expect(errors).to include('Links missing text for http://example.com')
  end

  it 'adds link text missing error on missing link text & :' do
    subject.update(links: 'http://example.com')
    errors = subject.errors.full_messages
    expect(errors).to include('Links missing text for http')
  end

  it 'adds link must have http error on missing http://' do
    subject.update(links: 'Example link:example.com')
    errors = subject.errors.full_messages
    expect(errors).to include('Links must include http:// or https://')
  end

  it 'allows https://' do
    subject.update(links: 'Example link:https://example.com')
    expect(subject.links).to eq('Example link' => 'https://example.com')
  end
end
