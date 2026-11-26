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

  context 'when accepting a proposal with guide images' do
    let(:lesson) { create(:exercise) }
    let(:proposal) { create(:exercise, :proposal, changed_lesson: lesson) }

    it 'copies the classroom layouts and photo guides onto the lesson' do
      %i[classroom_layouts photo_guides].each do |attr|
        proposal.public_send(attr).attach(io: file_fixture('landscape.png').open, filename: "#{attr}.png",
                                          content_type: 'image/png')
      end

      expect(lesson.replace_with(proposal)).to be(true)
      lesson.reload
      expect(lesson.classroom_layouts.blobs).to eq(proposal.classroom_layouts.blobs)
      expect(lesson.photo_guides.blobs).to eq(proposal.photo_guides.blobs)
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

    it 'adds a Classroom Layout page headed with the group and activity' do
      attach_fixture(:classroom_layouts, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(2)
      expect(pages.last[:strings]).to include('Test Exercise', 'Classroom Layout:', '2')
    end

    it 'labels each group once, without numbering the pictures' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:classroom_layouts, 'portrait')
      attach_fixture(:photo_guides, 'landscape')
      attach_fixture(:photo_guides, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(4)
      expect(pages.flat_map { |p| p[:strings] }.grep(/\d:\z/)).to be_empty
      # two landscape layouts share a page; the portrait one doesn't fit with anything
      expect(pages[1][:strings].count('Classroom Layout:')).to eq(1)
      expect(pages[2][:strings]).to include('Classroom Layout:')
      expect(pages[3][:strings].count('Photo Guide:')).to eq(1)
      expect(pages[3][:strings]).to include('4')
    end

    it 'labels the group change when layouts and photos share a page' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:photo_guides, 'landscape')

      pages = guide_pages
      expect(pages.size).to eq(2)
      expect(pages.last[:strings]).to include('Classroom Layout:', 'Photo Guide:')
    end

    it 'gives each image its own page when sharing would shrink them too much' do
      attach_fixture(:classroom_layouts, 'landscape')
      attach_fixture(:photo_guides, 'portrait')

      pages = guide_pages
      expect(pages.size).to eq(3)
      expect(pages[1][:strings]).to include('Classroom Layout:')
      expect(pages[1][:strings]).not_to include('Photo Guide:')
      expect(pages[2][:strings]).to include('Photo Guide:', '3')
    end

    it 'rejects guide images that are not PNG or JPG' do
      exercise.photo_guides.attach(io: StringIO.new('%PDF'), filename: 'guide.pdf',
                                   content_type: 'application/pdf')

      expect(exercise).not_to be_valid
      expect(exercise.errors[:photo_guides]).to be_present
    end
  end
end
