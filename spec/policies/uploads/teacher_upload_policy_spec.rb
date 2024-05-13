# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeacherUploadPolicy do
  subject(:policy) { described_class.new(user, nil) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'unauthorized user except new'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'
  end

  context 'when OrgAdmin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'unauthorized user except new'
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'
  end
end
