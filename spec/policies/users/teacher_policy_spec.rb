# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeacherPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { build(:user, :teacher) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'fully authorized user'
  end

  context 'when org admin' do
    context "when admin of teacher's org" do
      let(:user) { build(:user, :org_admin, organisation: record.organisation) }

      it_behaves_like 'fully authorized user'
    end

    context 'when admin of different org' do
      let(:user) { create(:user, :org_admin) }

      it_behaves_like 'unauthorized user'
    end
  end

  context 'when school manager' do
    context "when manager of teacher's school" do
      let(:school) { create(:school) }
      let(:user) { build(:user, :school_manager, schools: [school]) }

      before do
        school.teachers << record
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when manager of different school' do
      let(:user) { build(:user, :school_manager) }

      before do
        record.schools << create(:school)
        record.save
      end

      it_behaves_like 'unauthorized user'
    end
  end

  context 'when teacher' do
    context 'when interacting with self' do
      let(:user) { record }

      it_behaves_like 'authorized user for editing'
    end

    context 'when interacting with another teacher' do
      let(:user) { create(:user, :teacher) }

      it_behaves_like 'unauthorized user'
    end
  end
end
