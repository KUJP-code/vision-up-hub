# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Announcement do
  it 'has a valid factory'  do
    expect(build(:announcement)).to be_valid
  end

  # with valid link, with external link, with link that reaches resue
  it 'does not accept external links' do
    external_link_announcement = build(:announcement, link: 'www.youtube.com')
    error = 'Link can only be within the site'
    external_link_announcement.valid?
    expect(external_link_announcement.errors.full_messages).to include(error)
  end

  it 'provides an error when the link is invalid' do
    invalid_link_announcement = build(:announcement, link: 'thp .youtube.com')
    error = 'Link thp .youtube.com is not a valid URL'
    invalid_link_announcement.valid?
    expect(invalid_link_announcement.errors.full_messages).to include(error)
  end
end
