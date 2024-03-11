# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Test do
  subject(:test) { build(:test) }

  it 'has a valid factory' do
    expect(test).to be_valid
  end

  context 'when processing questions' do
    it 'produces a hash of max scores keyed by skills given correct input' do
      test.questions = "writing: 2, 3, 4\nreading: 5, 4 \nlistening: 2, 3, 6 \nspeaking: 10"
      test.save
      expect(test.questions).to eq(
        {
          'writing' => [2, 3, 4],
          'reading' => [5, 4],
          'listening' => [2, 3, 6],
          'speaking' => [10]
        }
      )
    end

    it 'splits skills on newlines' do
      test.questions = "listening: 4\nreading: 4 \nspeaking: 4 \nwriting: 4"
      test.save
      expect(test.questions.keys).to eq(described_class::SKILLS)
    end

    it 'ignores skills with no max scores entered' do
      test.questions = "writing: 4\nreading: \nlistening: 4 \nspeaking: 4"
      test.save
      expect(test.questions.keys).to eq(%w[writing listening speaking])
    end

    it 'ignores scores with no skill entered' do
      test.questions = "writing: \nreading: 4 \nlistening: 4 \nspeaking: 4"
      test.save
      expect(test.questions).to eq({ 'reading' => [4], 'listening' => [4], 'speaking' => [4] })
    end

    it 'automatically capitalizes skills' do
      test.questions = "lIsTeNiNg: 4 \nreaDing: 4 \nspeaking: 4\nwriting: 4"
      test.save
      expect(test.questions.keys).to eq(described_class::SKILLS)
    end

    it 'strips all whitespace before processing skills' do
      test.questions = "   writing: 4\nreading   : 4 \nlistening:    4 \nspea   king: 4"
      test.save
      expect(test.questions).to eq(
        { 'writing' => [4], 'reading' => [4], 'listening' => [4], 'speaking' => [4] }
      )
    end

    it 'gives a descriptive error if invalid skill entered' do
      test.questions = "writing: 3, 4\nPizza: 5, 6"
      test.save
      errors = test.errors.full_messages
      expect(errors).to include('Questions : Pizza is not a valid skill')
    end

    it 'transforms comma separated integers after skills to array of max scores' do
      test.questions = "writing: 3, 4\nreading: 5, 6"
      test.save
      expect(test.questions.values).to eq([[3, 4], [5, 6]])
    end

    it 'strips unnecessary whitespace from max scores' do
      test.questions = "writing: 3   , 4\nreading: 5,    6"
      test.save
      expect(test.questions.values).to eq([[3, 4], [5, 6]])
    end

    it 'gives a descriptive error if : missing from pair' do
      test.questions = "writing: 3, 4\nreading 5, 6"
      test.save
      errors = test.errors.full_messages
      expect(errors).to include("Missing ':' near reading5,6")
    end

    it 'gives a descriptive error if negative integer entered' do
      test.questions = "writing: 3, -4\nreading: 5, 6"
      test.save
      errors = test.errors.full_messages
      expect(errors).to include('Questions : -4 is not a valid max score')
    end

    it 'gives a descriptive error if integer larger than 15 entered' do
      test.questions = "writing: 3, 16\nreading: 5, 6"
      test.save
      errors = test.errors.full_messages
      expect(errors).to include('Questions : 16 is not a valid max score')
    end
  end

  context 'when processing thresholds' do
    it 'produces a hash of thresholds keyed by levels given correct input' do
      test.thresholds = "Sky One:60\nSky Two:70\nSky Three:80\n Galaxy One:90\n Galaxy Two:100"
      test.save
      expect(test.thresholds).to eq(
        {
          'Sky One' => 60,
          'Sky Two' => 70,
          'Sky Three' => 80,
          'Galaxy One' => 90,
          'Galaxy Two' => 100
        }
      )
    end

    it 'splits skills on newlines' do
      test.thresholds = "Sky One:60\nSky Two:70\nSky Three:80"
      test.save
      expect(test.thresholds.keys).to eq(['Sky One', 'Sky Two', 'Sky Three'])
    end

    it 'strips unnecessary whitespace' do
      test.thresholds = "Sky One: 60\nSky Two   : 70\nSky Three: 80"
      test.save
      expect(test.thresholds).to eq({ 'Sky One' => 60, 'Sky Two' => 70, 'Sky Three' => 80 })
    end

    it 'gives a descriptive error if : missing from pair' do
      test.thresholds = "Sky One:60\nSky Two 70"
      test.save
      expect(test.errors.full_messages).to include("Missing ':' near Sky Two 70")
    end

    it 'gives a descriptive error if invalid level entered' do
      test.thresholds = "Ski One:60\nSky Two:70\nSky Three:80"
      test.save
      expect(test.errors.full_messages).to include('Thresholds : Ski One is not a valid level')
    end

    it 'gives a descriptive error if level missing' do
      test.thresholds = "Sky One:60\n:70"
      test.save
      expect(test.errors.full_messages).to include('Thresholds : Missing level for threshold 70')
    end

    it 'gives a descriptive error if threshold missing' do
      test.thresholds = "Sky One:\nSky Two:70"
      test.save
      expect(test.errors.full_messages).to include('Thresholds : Missing threshold for Sky One')
    end

    it 'gives a descriptive error if threshold greater than 100' do
      test.thresholds = "Sky One:101\nSky Two:70"
      test.save
      expect(test.errors.full_messages).to include('Thresholds : 101 is not a valid threshold')
    end

    it 'gives a descriptive error if threshold less than 0' do
      test.thresholds = "Sky One:-1\nSky Two:70"
      test.save
      expect(test.errors.full_messages).to include('Thresholds : -1 is not a valid threshold')
    end
  end
end
