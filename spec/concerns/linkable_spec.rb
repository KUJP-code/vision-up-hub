# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Linkable do
  subject(:daily_activity) { build(:daily_activity) }

  let(:link_hash) do
    { 'Example link' => 'http://example.com',
      'Seasonal' => 'http://example.com/seasonal' }
  end

  it 'links as hash, pairs split by line and value split by colon' do
    daily_activity.links = "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    daily_activity.save
    expect(daily_activity.links).to eq(link_hash)
  end

  it 'strips unnecessary whitespace' do
    daily_activity.links = "Example link:  http://example.com\n Seasonal:http://example.com/seasonal"
    daily_activity.save
    expect(daily_activity.links).to eq(link_hash)
  end

  it 'resolves empty input to empty hash' do
    daily_activity.links = ''
    daily_activity.save
    expect(daily_activity.links).to eq({})
  end

  it 'adds link missing error on missing link' do
    daily_activity.links = 'Example link:'
    daily_activity.save
    errors = daily_activity.errors.full_messages
    expect(errors).to include('Links missing for Example link')
  end

  it 'adds link missing error on missing link & :' do
    daily_activity.links = 'Example link'
    daily_activity.save
    errors = daily_activity.errors.full_messages
    expect(errors).to include('Links missing for Example link')
  end

  it 'adds link text missing error on missing link text' do
    daily_activity.links = ': http://example.com'
    daily_activity.save
    errors = daily_activity.errors.full_messages
    expect(errors).to include('Links missing text for http://example.com')
  end

  it 'adds link text missing error on missing link text & :' do
    daily_activity.links = 'http://example.com'
    daily_activity.save
    errors = daily_activity.errors.full_messages
    expect(errors).to include('Links missing text for http')
  end

  it 'adds link must have http error on missing http://' do
    daily_activity.links = 'Example link:example.com'
    daily_activity.save
    errors = daily_activity.errors.full_messages
    expect(errors).to include('Links must include http:// or https://')
  end

  it 'allows https://' do
    daily_activity.links = 'Example link:https://example.com'
    daily_activity.save
    expect(daily_activity.links).to eq('Example link' => 'https://example.com')
  end
end
