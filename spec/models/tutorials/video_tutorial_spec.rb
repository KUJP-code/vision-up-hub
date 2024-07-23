# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VideoTutorial do
  it 'has a valid factory' do
    expect(build(:video_tutorial)).to be_valid
  end

  it 'provides specific error if an invalid URL is entered' do
    tutorial = build(:video_tutorial, video_path: 'thp:/youtube.com')
    error = "Video path #{tutorial.video_path} is not a valid URL"
    tutorial.valid?
    expect(tutorial.errors.full_messages).to include(error)
  end

  it 'does not accept hosts other than YT/Vimeo' do
    tutorial = build(:video_tutorial, video_path: 'https://www.google.com')
    error = "Video path #{tutorial.video_path} does not include #{VideoTutorial::VALID_HOSTS.join(' or ')}"
    tutorial.valid?
    expect(tutorial.errors.full_messages).to include(error)
  end

  context 'when converting YouTube link' do
    it 'automatically converts YT URL to embeddable version' do
      tutorial = create(:video_tutorial,
                        video_path: 'https://www.youtube.com/watch?v=1')
      expect(tutorial.video_path)
        .to eq("#{VideoTutorial::YOUTUBE_EMBED_PATH}1")
    end

    it 'does not alter converted links when other fields updated' do
      tutorial = create(:video_tutorial)
      converted_link = tutorial.video_path
      tutorial.update(title: 'New Title')
      expect(tutorial.video_path).to eq(converted_link)
    end

    it 'updates converted link when new link given' do
      tutorial = create(:video_tutorial,
                        video_path: 'https://www.youtube.com/watch?v=old')
      tutorial.update(video_path: 'https://www.youtube.com/watch?v=new')
      expect(tutorial.video_path)
        .to eq("#{VideoTutorial::YOUTUBE_EMBED_PATH}new")
    end
  end

  context 'when converting Vimeo link' do
    it 'automatically converts Vimeo URL to embeddable version' do
      tutorial = create(:video_tutorial,
                        video_path: 'https://vimeo.com/1')
      expect(tutorial.video_path).to eq("#{VideoTutorial::VIMEO_EMBED_PATH}1")
    end

    it 'does not alter converted links when other fields updated' do
      tutorial = create(:video_tutorial)
      converted_link = tutorial.video_path
      tutorial.update(title: 'New Title')
      expect(tutorial.video_path).to eq(converted_link)
    end

    it 'updates converted link when new link given' do
      tutorial = create(:video_tutorial,
                        video_path: 'https://vimeo.com/old')
      tutorial.update(video_path: 'https://vimeo.com/new')
      expect(tutorial.video_path).to eq("#{VideoTutorial::VIMEO_EMBED_PATH}new")
    end
  end
end
