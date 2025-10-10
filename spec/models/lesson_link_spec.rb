# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonLink, type: :model do
  describe 'validations' do
    it 'requires a url' do
      link = build(:lesson_link, url: nil)
      expect(link).not_to be_valid
      # locale-agnostic assertion
      expect(link.errors.added?(:url, :blank)).to be(true)
    end

    it 'rejects invalid URL strings' do
      link = build(:lesson_link, url: 'not a url')
      expect(link).not_to be_valid
      # depending on your model’s error symbol/message
      expect(link.errors[:url]).to be_present
    end

    it 'rejects unsupported schemes (e.g., ftp)' do
      link = build(:lesson_link, url: 'ftp://example.com/file')
      expect(link).not_to be_valid
    end
  end

  describe 'classification' do
    it 'detects YouTube links as video and converts to embed' do
      link = create(:lesson_link, :youtube)
      expect(link.kind).to eq('video')
      expect(link.url).to include('youtube.com/embed')
    end

    it 'detects Vimeo links as video and converts to embed' do
      link = create(:lesson_link, :vimeo)
      expect(link.kind).to eq('video')
      expect(link.url).to include('player.vimeo.com/video')
    end

    it 'detects Google Docs links as resource and normalizes to /preview' do
      link = create(:lesson_link, :google_doc)
      expect(link.kind).to eq('resource')
      expect(link.url).to end_with('/preview')
    end

    it 'treats unrecognized hosts as generic resource' do
      link = create(:lesson_link, url: 'https://example.com/stuff')
      expect(link.kind).to eq('resource')
      expect(link.url).to eq('https://example.com/stuff')
    end
  end

  describe 'google docs normalization' do
    it 'normalizes /edit to /preview' do
      link = create(:lesson_link, url: 'https://docs.google.com/document/d/xyz/edit')
      expect(link.kind).to eq('resource')
      expect(link.url).to end_with('/preview')
    end

    it 'normalizes /view to /preview' do
      link = create(:lesson_link, url: 'https://docs.google.com/document/d/xyz/view')
      expect(link.url).to end_with('/preview')
    end

    it 'does not change drive links' do
      link = create(:lesson_link, url: 'https://drive.google.com/file/d/abc/view')
      expect(link.kind).to eq('resource')
      expect(link.url).to eq('https://drive.google.com/file/d/abc/view')
    end
  end

  describe 'normalization niceties' do
    it 'strips whitespace around URL' do
      # Only if you implemented trimming in the model
      link = create(:lesson_link, url: '  https://youtu.be/abc123  ')
      expect(link.url).to include('youtube.com/embed/abc123')
    end
  end

  describe 'kind inference' do
    it 'sets kind=video for youtube and vimeo, resource otherwise' do
      expect(create(:lesson_link, url: 'https://youtu.be/abc').kind).to eq('video')
      expect(create(:lesson_link, url: 'https://vimeo.com/123').kind).to eq('video')
      expect(create(:lesson_link, url: 'https://example.org/doc').kind).to eq('resource')
    end
  end

  describe 'associations' do
    it 'destroys links when the lesson is destroyed' do
      # Only if Lesson has: has_many :lesson_links, dependent: :destroy
      lesson = create(:english_class)
      create(:lesson_link, lesson:, url: 'https://youtu.be/abc123')
      expect { lesson.destroy }.to change { LessonLink.count }.by(-1)
    end
  end

  # If you kept an embed_url column and sync it, include these:
  context 'when embed_url column is present' do
    it 'mirrors final video URL to embed_url' do
      link = create(:lesson_link, url: 'https://youtu.be/abc123')
      expect(link.embed_url).to eq(link.url) if link.respond_to?(:embed_url)
    end
  end
end
