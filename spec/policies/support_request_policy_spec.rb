# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportRequestPolicy do
  subject(:policy) { described_class.new(user, support_request) }

  let(:support_request) { build(:support_request) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'fully authorized user'
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user except new'
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'fully authorized user'
  end

  context 'when org admin' do
    context 'when viewing own support request' do
      let(:user) { create(:user, :org_admin) }

      before do
        user.support_requests << support_request
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when viewing organisation support requests' do
      let(:user) { create(:user, :org_admin) }
      let(:requester) do
        build(:user, :teacher, organisation_id: user.organisation_id)
      end

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when viewing other org support requests' do
      let(:user) { create(:user, :org_admin) }
      let(:requester) do
        create(:user, :school_manager, organisation: create(:organisation))
      end

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'unauthorized user except new'
    end
  end

  context 'when school manager' do
    context 'when viewing own requests' do
      let(:user) { create(:user, :school_manager) }

      before do
        user.support_requests << support_request
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when manager of requester school' do
      let(:user) { create(:user, :school_manager, schools: [create(:school)]) }
      let(:requester) do
        create(:user, :teacher, schools: [user.schools.first])
      end

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when requester is from different school' do
      let(:user) { build(:user, :school_manager) }
      let(:requester) { build(:user, :teacher, schools: []) }

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'unauthorized user except new'
    end
  end

  context 'when teacher' do
    let(:user) { create(:user, :teacher) }

    context 'when viewing own requests' do
      before do
        user.support_requests << support_request
      end

      it_behaves_like 'fully authorized user'
    end

    context 'when viewing other user requests' do
      it_behaves_like 'unauthorized user except new'
    end
  end
end
