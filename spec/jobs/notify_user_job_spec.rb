# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotifyUserJob do
  describe '#perform' do
    {
      'youtube.com' => 'https://youtube.com',
      'https://youtube.com/watch?v=abc#details' => 'https://youtube.com/watch?v=abc#details',
      '//youtube.com/watch?v=abc' => 'https://youtube.com/watch?v=abc',
      'vision-up.app/en/teacher_events?section=2#materials' => '/en/teacher_events?section=2#materials',
      'https://hub.kids-up.app/en/tutorials?section=2#files' => '/en/tutorials?section=2#files',
      'https://www.vision-up.app/en/tests' => '/en/tests',
      'https://vision-up.app.example.com/en/tests' => 'https://vision-up.app.example.com/en/tests',
      '/en/tests?level=1#results' => '/en/tests?level=1#results',
      '' => ''
    }.each do |input, expected|
      it "delivers #{input.inspect} as #{expected.inspect}" do
        user = instance_double(User)
        allow(User).to receive(:find).with(123).and_return(user)
        expect(user).to receive(:notify) do |notification|
          expect(notification.link).to eq(expected)
          expect(notification.text).to eq('Check this link')
        end

        described_class.new.perform(user_id: 123, text: 'Check this link', link: input)
      end
    end
  end
end
