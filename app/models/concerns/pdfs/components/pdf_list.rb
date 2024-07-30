# frozen_string_literal: true

module PdfList
  include PdfDefaults

  def array_to_list(array, style = nil)
    case style
    when :number
      array.map.with_index { |step, i| "#{i + 1}. #{step}" }
           .join("\n")
    when :dot
      array.map { |step| "• #{step}" }.join("\n")
    else
      array.join("\n")
    end
  end
end
