# frozen_string_literal: true

class DailyActivity < Lesson
  before_validation :set_links, :set_steps

  enum subtype: {
    discovery: 0,
    brain_training: 1,
    dance: 2,
    games: 3,
    imagination: 4,
    life_skills: 5,
    drawing: 6
  }

  def save_guide
    key = "#{course.root_path}/week_#{week}/#{day}/daily_activity/#{level}/guide.pdf"
    pdf = generate_guide_tempfile
    guide.purge
    guide.attach(io: pdf, filename: 'guide.pdf', content_type: 'application/pdf', key:)
  end

  def generate_guide_tempfile
    Tempfile.create do |f|
      generate_guide.render_file(f)
      f.flush
      File.open(f)
    end
  end

  def generate_guide
    pdf = Prawn::Document.new

    pdf.text title, size: 24
    pdf.text summary
    pdf.text "Week #{week}"
    pdf.text day.capitalize
    pdf.text subtype.capitalize
    pdf.text 'Steps:', size: 18
    steps.each_with_index { |s, i| pdf.text "#{i + 1}. #{s}" }
    pdf.text 'Links:', size: 18
    links.each do |k, v|
      pdf.text "<color rgb='0000FF'><u><link href='#{v}'>#{k}</link></u></color>", inline_format: true
    end

    pdf
  end

  private

  def set_links
    return unless links.instance_of?(String)

    pairs = links.split("\n")
    self.links = pairs.to_h { |pair| pair.split(':', 2).map(&:strip) }
  end

  def set_steps
    return unless steps.instance_of?(String)

    self.steps = steps.split("\n")
  end
end
