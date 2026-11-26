# frozen_string_literal: true

# Extra pages after the main guide page for full-size images, in groups
# (e.g. Classroom Layout, Photo Guide). Images go in order, one per page or
# two stacked when both still fit at a decent size. Each page is headed with
# the group its first image belongs to; if the group changes partway down a
# page, the new group's label goes above that image.
module PdfImagePage
  include PdfBackground, PdfDefaults, PdfFooter, PdfHeaderItem, PdfImage

  # The white box on the image_page background
  IMAGE_AREA_X   = 25.mm
  IMAGE_AREA_W   = 160.mm
  IMAGE_AREA_TOP = 247.mm
  IMAGE_AREA_H   = 220.mm
  IMAGE_AREA_BOTTOM = IMAGE_AREA_TOP - IMAGE_AREA_H

  SECTION_LABEL_H = 9.mm
  SECTION_GAP     = 6.mm
  SHARED_IMAGE_H  = (IMAGE_AREA_H - SECTION_GAP) / 2
  # Only share a page if neither image ends up smaller than this much of the
  # size it would be on a page of its own.
  MIN_SHARED_SCALE = 0.75

  # groups: [{ label: 'Photo Guide:', blobs: [...] }, ...]; empty groups are skipped
  # title: the activity name, shown small above the group label on each page
  def add_image_pages(pdf:, level:, groups:, title:)
    sections = groups.flat_map { |g| g[:blobs].map { |blob| { blob:, label: g[:label] } } }

    paginate_sections(sections).each do |page|
      new_image_page(pdf:, level:, header: { pre: title, main: page.first[:label], sub: '' }) do
        draw_page_sections(pdf, page)
      end
    end
  end

  # Page number for the main guide page: only numbered if more pages follow.
  def first_page_number(*attachments)
    attachments.any?(&:attached?) ? '1' : nil
  end

  # Blobs for a has_many_attached, in upload order.
  def image_blobs(attachments)
    return [] unless attachments.attached?

    attachments.attachments.sort_by(&:id).map(&:blob)
  end

  private

  # Pairs each image with the next one when they fit on a page together.
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
    PdfHeaderItemFactory.new(pdf).draw_default_header(text: header)
    yield
    draw_footer(pdf:, level:, page_num: pdf.page_number.to_s)
  end

  def draw_page_sections(pdf, page)
    first, second = page
    return draw_page_image(pdf, first[:blob], top: IMAGE_AREA_TOP, height: IMAGE_AREA_H) unless second

    draw_page_image(pdf, first[:blob], top: IMAGE_AREA_TOP, height: SHARED_IMAGE_H)

    top = IMAGE_AREA_TOP - SHARED_IMAGE_H - SECTION_GAP
    if new_group?(page)
      draw_section_label(pdf, second[:label], top:)
      top -= SECTION_LABEL_H
    end
    draw_page_image(pdf, second[:blob], top:, height: top - IMAGE_AREA_BOTTOM)
  end

  def new_group?(page)
    page.size == 2 && page.first[:label] != page.last[:label]
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

  def share_page?(pair)
    heights = [SHARED_IMAGE_H, SHARED_IMAGE_H - (new_group?(pair) ? SECTION_LABEL_H : 0)]

    pair.zip(heights).all? do |section, shared_h|
      width, height = image_dimensions(section[:blob])
      next false unless width.to_i.positive? && height.to_i.positive?

      fit_scale(width, height, IMAGE_AREA_H) * MIN_SHARED_SCALE <= fit_scale(width, height, shared_h)
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
