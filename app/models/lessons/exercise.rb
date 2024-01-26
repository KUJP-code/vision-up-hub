# frozen_string_literal: true

class Exercise < Lesson
  include Linkable

  def save_guide
    filename = "#{Time.zone.now.to_i}_#{title.parameterize(separator: '_')}_guide.pdf"
    key = "exercise/#{level}/" + filename
    pdf_io = guide_tempfile
    guide.attach(io: pdf_io, filename:, content_type: 'application/pdf', key:)
    pdf_io
  end

  private

  def guide_tempfile
    Tempfile.create do |f|
      generate_guide.render_file(f)
      File.open(f)
    end
  end

  def generate_guide
    pdf = Prawn::Document.new

    pdf.text title, size: 24
    pdf.text summary
    pdf.text 'Links:', size: 18
    links.each do |k, v|
      pdf.text "<color rgb='0000FF'><u><link href='#{v}'>#{k}</link></u></color>", inline_format: true
    end

    pdf
  end
end
