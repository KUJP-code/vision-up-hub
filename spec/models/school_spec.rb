# frozen_string_literal: true

require 'rails_helper'

RSpec.describe School do
  it 'has a valid factory' do
    expect(build(:school)).to be_valid
  end

  context 'when adding IP addresses' do
    it 'accepts a valid IP' do
      valid_ip = build(:school, ip: '127.0.0.1')
      expect(valid_ip).to be_valid
    end

    it 'throw descriptive error if invalid IP address provided' do
      invalid_ip = build(:school, ip: 'invalid')
      invalid_ip.valid?
      expect(invalid_ip.errors[:ip])
        .to include(' invalid is not a valid IP address')
    end

    it 'allows wildcard (*) as a valid IP address' do
      school = create(:school, ip: '*')
      expect(school.ip).to eq('*')
    end

    it 'accepts blank IP address' do
      school = build(:school, ip: '')
      expect(school).to be_valid
    end
  end
end
