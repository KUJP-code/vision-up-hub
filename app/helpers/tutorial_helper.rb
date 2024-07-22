# frozen_string_literal: true

module TutorialHelper
  # Converts a file to its embeddable form if it is not already embedded
  # NOTE: experimented with how to handle failures here, sending back invalid link means it won't validate in the model
  # which saves some headaches where people input really odd links that somehow make it through (found some in testing)
  def convert_video_link(link)
    return link if embed_link?(link)

    begin
      if link.include?('youtube.com') || link.include?('youtu.be')
        convert_youtube_link(link)
      elsif link.include?('vimeo.com')
        convert_vimeo_link(link)
      else
        link
      end
    rescue StandardError
      'Invalid link'
    end
  end

  private

  def embed_link?(link)
    link.include?('youtube.com/embed') || link.include?('player.vimeo.com/video')
  end

  def convert_youtube_link(link)
    video_id = if link.include?('youtu.be')
                 link.split('/').last
               else
                 CGI.parse(URI.parse(link).query)['v'].first
               end
    "https://www.youtube.com/embed/#{video_id}"
  rescue StandardError
    'Invalid link'
  end

  def convert_vimeo_link(link)
    video_id = link.split('/').last
    "https://player.vimeo.com/video/#{video_id}"
  rescue StandardError
    'Invalid link'
  end
end
