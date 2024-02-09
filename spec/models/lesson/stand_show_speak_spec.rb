# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StandShowSpeak do
  it 'has a valid factory' do
    expect(build(:stand_show_speak)).to be_valid
  end

  it_behaves_like 'lesson'
end
