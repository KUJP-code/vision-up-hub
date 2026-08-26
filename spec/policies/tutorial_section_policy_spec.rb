# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TutorialSectionPolicy do
  subject(:policy) { described_class.new(user, build(:tutorial_section)) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'authorized user for viewing'
  end
end
