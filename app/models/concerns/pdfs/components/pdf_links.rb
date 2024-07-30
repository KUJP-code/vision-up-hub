# frozen_string_literal: true

module PdfLinks
  include PdfDefaults

  def links_from_hash(links)
    link_array = links.map do |k, v|
      "<color rgb='645880'><u><link href='#{v}'>#{k}</link></u></color>"
    end
    link_array.join("\n")
  end
end
