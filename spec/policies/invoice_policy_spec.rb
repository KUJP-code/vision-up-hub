# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoicePolicy do
  subject(:policy) { described_class.new(user, invoice) }

  let!(:invoice) { create(:invoice) }
  let(:admin) { create(:user, :admin) }
  let(:non_admin) { create(:user, :teacher) }

  describe 'permissions' do
    context 'when user is an admin' do
      let(:user) { admin }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.to permit_action(:create) }
      it { is_expected.to permit_action(:edit) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'when user is not an admin' do
      let(:user) { non_admin }

      it { is_expected.not_to permit_action(:index) }
      it { is_expected.not_to permit_action(:show) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:edit) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end

  describe 'Scope' do
    let(:scope) { Pundit.policy_scope!(user, Invoice) }

    context 'when user is an admin' do
      let(:user) { admin }

      it 'includes all invoices' do
        expect(scope).to include(invoice)
      end
    end

    context 'when user is not an admin' do
      let(:user) { non_admin }

      it 'returns no invoices' do
        expect(scope).to be_empty
      end
    end
  end
end
