# frozen_string_literal: true

require 'rails_helper'

# This spec remains at the legacy path to preserve history through the model consolidation.
# rubocop:disable RSpec/FilePath, RSpec/SpecFilePathFormat
RSpec.describe TutorialCategory do
  it 'groups files, FAQs, links, and videos in one resource card' do
    resource = build(:tutorial_category, :mixed)
    resource.files.attach(
      io: Rails.root.join('spec/example_lesson.pdf').open,
      filename: 'guide.pdf', content_type: 'application/pdf'
    )

    expect(resource).to be_valid
    expect(resource.items.pluck('kind')).to contain_exactly('link', 'video', 'faq')
    expect(resource.files).to be_attached
  end

  it 'validates the content required by each item type' do
    resource = build(:tutorial_category, items: [{ 'kind' => 'faq', 'title' => 'How?', 'body' => '' }])

    expect(resource).not_to be_valid
    expect(resource.errors[:items]).to be_present
  end

  it 'builds embeddable YouTube and Vimeo URLs without changing stored links' do
    youtube = 'https://www.youtube.com/watch?v=1'
    vimeo = 'https://vimeo.com/2'

    expect(described_class.embed_url(youtube)).to eq("#{VideoEmbeddable::YOUTUBE_EMBED_PATH}1")
    expect(described_class.embed_url(vimeo)).to eq("#{VideoEmbeddable::VIMEO_EMBED_PATH}2")
  end

  it 'rejects unsupported video hosts but permits them for ordinary links' do
    video = build(:tutorial_category,
                  items: [{ 'kind' => 'video', 'title' => 'Video', 'url' => 'https://example.com/video' }])
    link = build(:tutorial_category,
                 items: [{ 'kind' => 'link', 'title' => 'Link', 'url' => 'https://example.com/video' }])

    expect(video).not_to be_valid
    expect(link).to be_valid
  end
end
# rubocop:enable RSpec/FilePath, RSpec/SpecFilePathFormat
