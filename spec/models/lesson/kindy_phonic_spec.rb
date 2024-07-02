# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KindyPhonic do
  it_behaves_like 'lesson'

  it 'has a valid factory' do
    expect(build(:kindy_phonic)).to be_valid
  end

  it 'ensures level is kindy' do
    kindy_phonic = create(:kindy_phonic, level: nil)
    expect(kindy_phonic.level).to eq('kindy')
  end

  context 'when setting topic' do
    it 'sets topic from lesson_topic, term and unit' do
      kindy_phonic = build(:kindy_phonic, lesson_topic: 'Topic',
                                          term: '1', unit: '1')
      kindy_phonic.save
      expect(kindy_phonic.topic).to eq('Term 1 Unit 1 - Topic')
    end

    it 'does not reset topic when released or approved' do
      kindy_phonic = create(:kindy_phonic, lesson_topic: 'Topic',
                                           term: '1', unit: '1')
      og_topic = kindy_phonic.topic
      kindy_phonic.update(admin_approval_id: 1, admin_approval_name: 'Admin',
                          topic: nil, term: nil, unit: nil)
      kindy_phonic.update(released: true)
      expect(kindy_phonic.reload.topic).to eq(og_topic)
    end
  end

  context 'when generating PDF guide' do
    it 'does not generate a PDF' do
      pdf = build(:kindy_phonic).attach_guide
      expect(pdf).to be_nil
    end
  end
end
