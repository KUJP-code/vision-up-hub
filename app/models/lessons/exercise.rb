# frozen_string_literal: true

class Exercise < Lesson
  include Linkable

  before_validation :set_links

  def save_guide
    key = "#{course.root_path}/week_#{week}/#{day}/exercise/#{level}/#{Time.zone.now.to_i}guide.pdf"
    pdf_io = guide_tempfile
    guide.attach(io: pdf_io, filename: 'guide.pdf', content_type: 'application/pdf', key:)
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
    pdf.text "Week #{week}"
    pdf.text day.capitalize
    pdf.text 'Links:', size: 18
    links.each do |k, v|
      pdf.text "<color rgb='0000FF'><u><link href='#{v}'>#{k}</link></u></color>", inline_format: true
    end

    pdf
  end
end
