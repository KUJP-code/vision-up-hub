# frozen_string_literal: true

# Extra pages after the main guide page for full-size images (photo guides,
# classroom layouts). Each image is a section; sections without an image are
# skipped. Neighbouring sections share a page, one above the other, when both
# still fit at a decent size; otherwise each gets a page to itself.
module PdfImagePage
  include PdfBackground, PdfDefaults, PdfFooter, PdfHeaderItem, PdfImage

  # The white box on the image_page background
  IMAGE_AREA_X   = 25.mm
  IMAGE_AREA_W   = 160.mm
  IMAGE_AREA_TOP = 247.mm
  IMAGE_AREA_H   = 220.mm

  SECTION_LABEL_H = 9.mm
  SECTION_GAP     = 6.mm
  # Only share a page if neither image ends up smaller than this much of the
  # size it would be on a page of its own.
  MIN_SHARED_SCALE = 0.75

  # sections: [{ blob:, header: { pre:, main:, sub: }, label: }, ...]
  #   blob   - the image (nil to skip the section)
  #   header - used when the image gets a page to itself
  #   label  - shown above the image when it shares a page
  # shared_header - used for pages where two sections share
  def add_image_pages(pdf:, level:, sections:, shared_header:)
    paginate_sections(sections.select { |s| s[:blob] }).each do |page_sections|
      header = page_sections.one? ? page_sections.first[:header] : shared_header

      new_image_page(pdf:, level:, header:) do
        if page_sections.one?
          draw_page_image(pdf, page_sections.first[:blob], top: IMAGE_AREA_TOP, height: IMAGE_AREA_H)
        else
          draw_shared_sections(pdf, page_sections)
        end
      end
    end
  end

  # Page number for the main guide page: only numbered if more pages follow.
  def first_page_number(*images)
    images.any?(&:attached?) ? '1' : nil
  end

  # Blobs for a has_one_attached / has_many_attached, in upload order.
  def image_blobs(attached)
    return [] unless attached.attached?
    return [attached.blob] unless attached.is_a?(ActiveStorage::Attached::Many)

    attached.attachments.sort_by(&:id).map(&:blob)
  end

  private

  # Pairs each section with the next one when they fit on a page together.
  def paginate_sections(sections)
    pages = []
    remaining = sections.dup
    until remaining.empty?
      pair = remaining.first(2)
      pages << (pair.size == 2 && share_page?(pair) ? remaining.shift(2) : remaining.shift(1))
    end
    pages
  end

  def new_image_page(pdf:, level:, header:)
    pdf.start_new_page
    add_background(pdf, 'image_page')
    PdfHeaderItemFactory.new(pdf).draw_default_header(text: { pre: '', main: '', sub: '' }.merge(header))
    yield
    draw_footer(pdf:, level:, page_num: pdf.page_number.to_s)
  end

  def draw_shared_sections(pdf, sections)
    section_h = shared_section_height(sections.size)

    sections.each_with_index do |section, i|
      top = IMAGE_AREA_TOP - (i * (section_h + SECTION_GAP))
      draw_section_label(pdf, section[:label], top:)
      draw_page_image(pdf, section[:blob], top: top - SECTION_LABEL_H, height: section_h - SECTION_LABEL_H)
    end
  end

  def draw_section_label(pdf, label, top:)
    pdf.bounding_box([IMAGE_AREA_X, top], width: IMAGE_AREA_W, height: SECTION_LABEL_H) do
      pdf.text sa(label), size: SUBHEADING_SIZE, valign: :center
    end
  end

  def draw_page_image(pdf, blob, top:, height:)
    PdfImageFactory.new(pdf:, x_pos: IMAGE_AREA_X, width: IMAGE_AREA_W)
                   .add_blob(blob:, y_pos: top, height:, position: :center)
  end

  def shared_section_height(count)
    (IMAGE_AREA_H - (SECTION_GAP * (count - 1))) / count
  end

  def share_page?(sections)
    image_h = shared_section_height(sections.size) - SECTION_LABEL_H

    sections.all? do |section|
      width, height = image_dimensions(section[:blob])
      next false unless width.to_i.positive? && height.to_i.positive?

      fit_scale(width, height, IMAGE_AREA_H) * MIN_SHARED_SCALE <= fit_scale(width, height, image_h)
    end
  end

  def fit_scale(width, height, box_height)
    [IMAGE_AREA_W / width, box_height / height].min
  end

  def image_dimensions(blob)
    blob.analyze unless blob.analyzed?
    blob.metadata.values_at('width', 'height')
  rescue StandardError => e
    Rails.logger.warn("Couldn't read image size for blob #{blob.id}: #{e.message}")
    nil
  end
end
