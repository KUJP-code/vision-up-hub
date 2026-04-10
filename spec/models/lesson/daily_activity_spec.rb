# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DailyActivity do
  subject(:daily_activity) do
    create(
      :daily_activity,
      title: 'Test Daily Activity',
      level: :kindy,
      subtype: :discovery,
      links: "Example link:http://example.com\nSeasonal:http://example.com/seasonal"
    )
  end

  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:daily_activity)).to be_valid
  end

  context 'when generating PDF guide' do
    it 'contains title, subcategory and instructions' do
      pdf = daily_activity.attach_guide
      text_analysis = PDF::Inspector::Text.analyze(pdf)
      expect(text_analysis.strings)
        .to include(
          'Test Daily Activity', 'Discovery', '1. Instruction 1', '2. Instruction 2'
        )
    end
  end

  context 'when accepting a proposal with images' do
    let(:lesson) { create(:daily_activity) }
    let(:proposal) { create(:daily_activity, :proposal, changed_lesson: lesson) }

    before do
      proposal.pdf_image.attach(
        io: StringIO.new('fake image data'),
        filename: 'proposal-image.png',
        content_type: 'image/png'
      )
    end

    it 'copies the attached blob without reopening the source file' do
      allow(proposal.pdf_image).to receive(:open).and_raise(StandardError, 'should not reopen')

      expect(lesson.replace_with(proposal)).to be(true)
      expect(lesson.reload.pdf_image).to be_attached
      expect(lesson.pdf_image.blob).to eq(proposal.pdf_image.blob)
    end
  end

  context 'when approving a writer-created lesson' do
    let(:writer) { create(:user, :writer) }
    let(:lesson) { create(:daily_activity, status: :proposed, creator: writer, assigned_editor: writer) }

    it 'updates the lesson status to accepted' do
      lesson.update(admin_approval_id: 1, admin_approval_name: 'Admin')

      expect(lesson.reload.status).to eq('accepted')
    end
  end
end
