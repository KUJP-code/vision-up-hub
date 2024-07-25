# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SupportRequestPolicy do
  subject(:policy) { described_class.new(user, support_request) }

  let(:support_request) { build(:support_request) }

  context 'when admin' do
    let(:user) { build(:user, :admin, organisation_id: 1) }

    it_behaves_like 'authorized user'

    it 'scopes to all support requests' do
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq(SupportRequest.all)
    end
  end

  context 'when writer' do
    let(:user) { create(:user, :writer) }

    context 'when own support request' do
      before do
        user.support_requests << support_request
      end

      it_behaves_like 'authorized user'
    end

    context 'when other support request' do
      it_behaves_like 'unauthorized user except new'
    end

    it 'scopes to empty relation' do
      user.support_requests << support_request
      create_list(:support_request, 2)
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq([support_request])
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales, organisation_id: 1) }

    it_behaves_like 'authorized user'

    it 'scopes to all support requests' do
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq(SupportRequest.all)
    end
  end

  context 'when org admin' do
    context 'when viewing own support request' do
      let(:user) { create(:user, :org_admin) }

      before do
        user.support_requests << support_request
      end

      it_behaves_like 'authorized user'
    end

    context 'when viewing organisation support requests' do
      let(:user) { create(:user, :org_admin) }
      let(:requester) do
        build(:user, :teacher, organisation_id: user.organisation_id)
      end

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'authorized user'
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

    it 'scopes to all support requests from their organisation' do
      user = create(:user, :org_admin)
      create(:user, :school_manager).support_requests << support_request
      org_requests = create_list(:support_request, 2, user:)
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq(org_requests)
    end
  end

  context 'when school manager' do
    context 'when viewing own requests' do
      let(:user) { create(:user, :school_manager) }

      before do
        user.support_requests << support_request
      end

      it_behaves_like 'authorized user'
    end

    context 'when manager of requester school' do
      let(:user) { create(:user, :school_manager, schools: [create(:school)]) }
      let(:requester) do
        create(:user, :teacher, schools: [user.schools.first])
      end

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'authorized user'
    end

    context 'when requester is from different school' do
      let(:user) { build(:user, :school_manager) }
      let(:requester) { build(:user, :teacher, schools: []) }

      before do
        requester.support_requests << support_request
      end

      it_behaves_like 'unauthorized user except new'
    end

    it 'scopes to all support requests from their school' do
      user = create(:user, :school_manager, schools: [create(:school)])
      create(:user, :org_admin).support_requests << support_request
      school_requests = create_list(
        :support_request, 2,
        user: create(:user, :teacher, schools: [user.schools.first])
      )
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq(school_requests)
    end
  end

  context 'when teacher' do
    let(:user) { create(:user, :teacher) }

    context 'when viewing own requests' do
      before do
        user.support_requests << support_request
      end

      it_behaves_like 'authorized user'
    end

    context 'when viewing other user requests' do
      it_behaves_like 'unauthorized user except new'
    end

    it 'scopes to own requests' do
      user.support_requests << support_request
      create_list(:support_request, 2)
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq([support_request])
    end
  end

  context 'when parent' do
    let(:user) { create(:user, :parent) }

    it_behaves_like 'unauthorized user except new'

    it 'scopes to own requests' do
      user.support_requests << support_request
      create_list(:support_request, 2)
      expect(Pundit.policy_scope!(user, SupportRequest)).to eq([support_request])
    end
  end
end
