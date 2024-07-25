# frozen_string_literal: true

RSpec.shared_examples 'authorized user' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.to authorize_action(:destroy) }
end

RSpec.shared_examples 'unauthorized user except new' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'authorized user except destroy' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'authorized user for editing' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'authorized user for viewing' do
  it { is_expected.to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end

RSpec.shared_examples 'unauthorized user' do
  it { is_expected.not_to authorize_action(:show) }
  it { is_expected.not_to authorize_action(:new) }
  it { is_expected.not_to authorize_action(:edit) }
  it { is_expected.not_to authorize_action(:create) }
  it { is_expected.not_to authorize_action(:update) }
  it { is_expected.not_to authorize_action(:destroy) }
end
