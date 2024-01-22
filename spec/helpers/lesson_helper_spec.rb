# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonHelper do
  context 'when using stringify_links' do
    it 'transforms links hash into string' do
      links = { 'Example link' => 'http://example.com', 'Seasonal' => 'http://example.com/seasonal' }
      expect(helper.stringify_links(links)).to eq("Example link:http://example.com\nSeasonal:http://example.com/seasonal")
    end
  end
end
