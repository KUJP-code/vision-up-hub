# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Exercise do
  subject(:exercise) do
    create(:exercise,
           title: 'Test Exercise', subtype: :jumping,
           instructions: "Instruction 1\nInstruction 2" )
  end

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:exercise)).to be_valid
  end

  context 'when accepting a proposal with classroom layouts' do
    let(:lesson) { create(:exercise) }
    let(:proposal) { create(:exercise, :proposal, changed_lesson: lesson) }

    it 'copies the layouts onto the lesson' do
      proposal.classroom_layouts.attach(io: file_fixture('landscape.png').open, filename: 'layout.png',
                                        content_type: 'image/png')

      expect(lesson.replace_with(proposal)).to be(true)
      expect(lesson.reload.classroom_layouts.blobs).to eq(proposal.classroom_layouts.blobs)
    end
  end

  context 'when generating PDF guide' do
    it 'contains title, subcategory and instructions' do
      pdf = exercise.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to include(
          'Test Exercise', 'Jumping', '1. Instruction 1', '2. Instruction 2'
        )
    end

    def attach_fixture(attr, name)
      exercise.public_send(attr).attach(io: file_fixture("#{name}.png").open,
                                        filename: "#{name}.png", content_type: 'image/png')
    end

    def guide_pages
      PDF::Inspector::Page.analyze(exercise.attach_guide).pages
    end

    it 'is a single page without extra images' do
      expect(guide_pages.size).to eq(1)
    end

    it 'adds a Classroom Layout page' do
      attach_fixture(:classroom_layouts, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(2)
      expect(pages.last[:strings]).to include('Classroom Layout:', 'Test Exercise', '2')
    end

    it 'puts both images on one page when they fit' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:image_page, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(2)
      expect(pages.last[:strings]).to include('Classroom Layout:', 'Photo guide:')
    end

    it 'numbers multiple classroom layouts and pairs them up where they fit' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:classroom_layouts, 'portrait')
      attach_fixture(:image_page, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(4)
      expect(pages[1][:strings]).to include('Classroom Layout 1:', 'Classroom Layout 2:')
      expect(pages[2][:strings]).to include('Classroom Layout 3:')
      expect(pages[2][:strings]).not_to include('Photo guide:')
      expect(pages[3][:strings]).to include('Photo guide', '4')
    end

    it 'rejects classroom layouts that are not images' do
      exercise.classroom_layouts.attach(io: StringIO.new('%PDF'), filename: 'layout.pdf',
                                        content_type: 'application/pdf')

      expect(exercise).not_to be_valid
      expect(exercise.errors[:classroom_layouts]).to be_present
    end

    it 'gives each image its own page when sharing would shrink them too much' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:image_page, 'portrait')

      pages = guide_pages
      expect(pages.size).to eq(3)
      expect(pages[1][:strings]).to include('Classroom Layout:')
      expect(pages[2][:strings]).to include('Photo guide', '3')
    end
  end
end
