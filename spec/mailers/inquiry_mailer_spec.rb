# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InquiryMailer do
  include ActiveSupport::Testing::TimeHelpers

  let(:received_at) { Time.zone.local(2026, 6, 19, 13, 45) }
  let(:inquiry) do
    build(
      :inquiry,
      email: 'customer@example.com',
      name: '山田 太郎',
      message: "資料について教えてください。\n電話での相談も希望します。",
      date_1: '2026-07-01',
      time_1: '10:00～',
      date_2: '2026-07-02',
      time_2: '14:00～'
    )
  end

  around do |example|
    travel_to(received_at) { example.run }
  end

  describe '#inquiry' do
    subject(:mail) { described_class.inquiry(inquiry) }

    it 'sends the internal inquiry email' do
      expect(mail.to).to contain_exactly(
        't-nakagawa@kids-up.jp',
        'p-jayson@kids-up.jp',
        'r-callan@p-up.jp'
      )
      expect(mail.reply_to).to contain_exactly('customer@example.com')
      expect(mail.subject).to eq('New VisionUP Inquiry')
      expect(mail.text_part.decoded).to include('受付日時: 2026年06月19日 13:45')
      expect(mail.text_part.decoded).to include('第1希望: 2026-07-01 10:00～')
      expect(mail.text_part.decoded).to include('第2希望: 2026-07-02 14:00～')
      expect(mail.text_part.decoded).to include('資料について教えてください。')
    end
  end

  describe '#confirmation' do
    subject(:mail) { described_class.confirmation(inquiry) }

    it 'sends a confirmation email to the customer' do
      expect(mail.to).to contain_exactly('customer@example.com')
      expect(mail.subject).to eq('【VisionUP】お問い合わせありがとうございます')
      expect(mail.text_part.decoded).to include('山田 太郎 様')
      expect(mail.text_part.decoded).to include('受付日時: 2026年06月19日 13:45')
      expect(mail.text_part.decoded).to include('第1希望: 2026-07-01 10:00～')
      expect(mail.text_part.decoded).to include('第2希望: 2026-07-02 14:00～')
      expect(mail.text_part.decoded).to include('資料について教えてください。')
    end
  end
end
