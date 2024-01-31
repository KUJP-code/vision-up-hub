# frozen_string_literal: true

RSpec.shared_examples 'authorized user' do
  it { is_expected.to authorize_action(:index) }
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
end
