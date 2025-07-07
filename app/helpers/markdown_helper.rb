# frozen_string_literal: true

require 'redcarpet'

module MarkdownHelper
  def markdown(text)
    @markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        filter_html:  true,
        hard_wrap:    true
      ),
      autolink:       true,
      tables:         true,
      fenced_code_blocks: true,
      strikethrough:  true
    )
    @markdown.render(text).html_safe
  end
end
