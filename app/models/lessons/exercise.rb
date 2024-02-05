# frozen_string_literal: true

class Exercise < Lesson
  include Linkable

  has_one_attached :image

  private

  def generate_guide
    pdf = Prawn::Document.new

    pdf.text title, size: 24
    if image.attached?
      pdf.image(
        StringIO.open(image.download),
        position: :right,
        vposition: :top,
        width: 200,
        height: 200
      )
    end
    pdf.text 'Links:', size: 18
    links.each do |k, v|
      pdf.text "<color rgb='0000FF'><u><link href='#{v}'>#{k}</link></u></color>", inline_format: true
    end

    pdf
  end
end
