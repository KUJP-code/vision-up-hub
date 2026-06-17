# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PearsonReportBatchPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:user) { create(:user, :admin) }
  let(:school) { create(:school, organisation: school_org) }
  let(:school_org) { user.organisation }
  let(:record) { create(:pearson_report_batch, school:, user:) }

  context 'when admin accesses an own-org batch' do
    it { is_expected.to authorize_action(:show) }
    it { is_expected.to authorize_action(:create) }
    it { is_expected.to authorize_action(:regenerate) }
  end

  context 'when admin accesses a cross-org batch' do
    let(:school_org) { create(:organisation) }

    it { is_expected.not_to authorize_action(:show) }
    it { is_expected.not_to authorize_action(:create) }
    it { is_expected.not_to authorize_action(:regenerate) }
  end
end
