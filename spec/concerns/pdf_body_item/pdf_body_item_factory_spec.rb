# frozen_string_literal: true

require 'spec_helper'
require 'prawn'
require 'prawn/measurement_extensions'
require_relative '../../../app/models/concerns/pdfs/pdf_defaults'
require_relative '../../../app/models/concerns/pdfs/components/pdf_body_item'

RSpec.describe PdfBodyItem::PdfBodyItemFactory do
  let(:pdf) do
    Prawn::Document.new(margin: 0, page_size: 'A4').tap do |document|
      document.font_families.update(
        'Shingo' => { normal: File.expand_path('../../../app/assets/fonts/shingo/ShinMGoPro-DeBold.ttf', __dir__) }
      )
      document.font 'Shingo'
    end
  end

  let(:japanese_instruction) do
    '動物のシルエットを見て、何の動物か当てましょう。必要に応じて動画を一時停止し、考える時間を十分に確保してください。'
  end

  let(:fragments) { [] }

  before do
    allow(pdf).to receive(:draw_text!).and_wrap_original do |original, string, options|
      fragments << [string, options[:at][1].round(2)]
      original.call(string, options)
    end
  end

  def rendered_lines(text, legacy: false)
    fragments.clear
    if legacy
      draw_legacy(text)
    else
      described_class.new(pdf).draw(text:, y_pos: 200.mm, height: 50.mm)
    end

    fragments.group_by(&:last).values.map { |parts| parts.map(&:first).join.delete("\u200B") }
  end

  def draw_legacy(text)
    pdf.bounding_box([48.mm, 200.mm], width: 140.mm, height: 50.mm) do
      pdf.text text, size: PdfDefaults::FONT_SIZE, overflow: :shrink_to_fit,
                     inline_format: true, min_font_size: 0
    end
  end

  it 'keeps a long Japanese instruction beside its number without changing the source' do
    text = "3. #{japanese_instruction}".freeze
    lines = rendered_lines(text)

    expect(lines.first).to start_with('3. 動物')
    expect(lines.length).to be > 1
    expect(lines.join).to eq(text)
  end

  it 'wraps mixed Japanese and English instructions without splitting short English phrases' do
    lines = rendered_lines("4. 「Let's count.」#{japanese_instruction}")

    expect(lines.first).to start_with("4. 「Let's count.」動物")
    expect(lines).not_to include('。')
  end

  it 'renders English-only guides exactly as before' do
    text = "1. Let's count the animals together. #{'Can you see a cat? ' * 12}\n2. Repeat with Jot."
    original_lines = rendered_lines(text, legacy: true)

    expect(rendered_lines(text)).to eq(original_lines)
  end

  it 'preserves inline formatting and Japanese link destinations' do
    url = 'https://example.com/動物'
    text = %(<a href="#{url}"><color rgb="FF0000">動物</color></a>)
    allow(pdf).to receive(:formatted_text).and_call_original

    rendered_lines(text)

    expect(pdf).to have_received(:formatted_text).with(
      [hash_including(text: "動\u200B物\u200B", link: url, color: 'FF0000')],
      hash_including(size: PdfDefaults::FONT_SIZE)
    )
  end
end
