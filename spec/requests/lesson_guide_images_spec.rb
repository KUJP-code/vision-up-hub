# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Lesson guide image uploads' do
  let(:user) { create(:user, :admin) }

  def upload(name)
    Rack::Test::UploadedFile.new(file_fixture("#{name}.png"), 'image/png')
  end

  before { sign_in user }

  {
    exercise: %i[classroom_layouts photo_guides],
    daily_activity: %i[photo_guides]
  }.each do |type, attrs|
    attrs.each do |attr|
      context "with #{type} #{attr}" do
        let(:lesson) { create(type) }
        let(:path) { public_send(:"#{type}_path", lesson) }

        it 'shows a multi-upload field on the edit form' do
          get edit_lesson_path(lesson)

          expect(response.body).to include("#{type}[#{attr}][]")
        end

        it 'can add several images at once' do
          patch path, params: { type => { attr => ['', upload('landscape'), upload('portrait')] } }

          expect(lesson.reload.public_send(attr).count).to eq(2)
        end

        it 'keeps existing images and removes ticked ones' do
          lesson.public_send(attr).attach([upload('landscape'), upload('portrait')])
          keep, remove = lesson.public_send(attr).blobs.order(:id).to_a

          patch path, params: { type => { attr => ['', keep.signed_id, remove.signed_id],
                                          resource_deletions: { attr => [remove.id.to_s] } } }

          expect(lesson.reload.public_send(attr).blobs).to contain_exactly(keep)
        end
      end
    end
  end
end
