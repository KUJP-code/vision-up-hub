# frozen_string_literal: true

module TutorialHelper
  # List of acceptable file types for uploads
  ACCEPTABLE_FILE_TYPES = [
    'application/pdf', # PDF
    'application/vnd.ms-powerpoint', # PPT
    'application/vnd.openxmlformats-officedocument.presentationml.presentation', # PPTX
    'application/vnd.ms-excel', # XLS
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', # XLSX
    'image/jpeg', # JPG
    'image/png' # PNG
  ].freeze

  def valid_file?(file)
    ACCEPTABLE_FILE_TYPES.include?(file.content_type)
  end

  def valid_video_link?(link)
    link.include?('youtube.com') || link.include?('youtu.be') || link.include?('vimeo.com')
  end

  # Converts a file to its embeddable form if it is not already embedded
  def convert_video_link(link)
    return link if embed_link?(link)

    if link.include?('youtube.com') || link.include?('youtu.be')
      convert_youtube_link(link)
    elsif link.include?('vimeo.com')
      convert_vimeo_link(link)
    else
      link
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
  end

  def convert_vimeo_link(link)
    video_id = link.split('/').last
    "https://player.vimeo.com/video/#{video_id}"
  end
end
