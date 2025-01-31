# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FilePolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { ActiveStorage::Blob.new }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.to authorize_action(:destroy) }

    it 'scopes to all files' do
      test_file = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to contain_exactly(test_file)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to all files' do
      test_file = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to contain_exactly(test_file)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it { is_expected.not_to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to no files' do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end

  context 'when OrgAdmin' do
    let(:user) { build(:user, :org_admin) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to no files' do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end

  context 'when SchoolManager' do
    let(:user) { build(:user) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to no files' do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end

  context 'when Teacher' do
    let(:user) { build(:user, :teacher) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to no files' do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end

  context 'when Parent' do
    let(:user) { build(:user, :parent) }

    it { is_expected.to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:destroy) }

    it 'scopes to no files' do
      ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/Brett_Tanner_Resume.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end
end
