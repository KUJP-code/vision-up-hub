# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Exercise classroom layouts' do
  let(:user) { create(:user, :admin) }
  let(:exercise) { create(:exercise) }

  def upload(name)
    Rack::Test::UploadedFile.new(file_fixture("#{name}.png"), 'image/png')
  end

  before { sign_in user }

  it 'shows the field on the edit form' do
    get edit_lesson_path(exercise)

    expect(response.body).to include('exercise[classroom_layouts][]')
  end

  it 'can add several layouts at once' do
    patch exercise_path(exercise),
          params: { exercise: { classroom_layouts: ['', upload('landscape'), upload('portrait')] } }

    expect(exercise.reload.classroom_layouts.count).to eq(2)
  end

  it 'keeps existing layouts and removes ticked ones' do
    exercise.classroom_layouts.attach([upload('landscape'), upload('portrait')])
    keep, remove = exercise.classroom_layouts.blobs.order(:id).to_a

    patch exercise_path(exercise),
          params: { exercise: { classroom_layouts: ['', keep.signed_id, remove.signed_id],
                                resource_deletions: { classroom_layouts: [remove.id.to_s] } } }

    expect(exercise.reload.classroom_layouts.blobs).to contain_exactly(keep)
  end
end
