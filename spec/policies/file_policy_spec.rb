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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
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
        io: Rails.root.join('spec/example_lesson.pdf').open,
        filename: 'file.pdf'
      )
      expect(described_class::Scope.new(user, ActiveStorage::Blob).resolve)
        .to be_empty
    end
  end

  context 'when the file is attached to a report card batch' do
    let(:user) { create(:user, :admin) }
    let(:school) { create(:school, organisation: user.organisation) }
    let(:batch) { create(:report_card_batch, school:, user:) }
    let(:record) do
      batch.file.attach(
        io: Rails.root.join('spec/example_lesson.pdf').open,
        filename: 'report.pdf',
        content_type: 'application/pdf'
      )
      batch.file.blob
    end

    it { is_expected.to authorize_action(:show) }

    context 'when the batch belongs to another organisation' do
      let(:school) { create(:school) }

      it { is_expected.not_to authorize_action(:show) }
    end
  end
end
