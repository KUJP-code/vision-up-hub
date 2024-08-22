# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormSubmissionPolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { build_stubbed(:form_submission) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all form submissions' do
      same_org = create(:form_submission,
                        parent: create(:user, :parent, organisation: user.organisation))
      diff_org = create(:form_submission, parent: create(:user, :parent))
      expect(Pundit.policy_scope!(user, FormSubmission)).to contain_exactly(same_org, diff_org)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      create(:form_submission,
             parent: create(:user, :parent, organisation: user.organisation))
      expect(Pundit.policy_scope!(user, FormSubmission)).to eq(FormSubmission.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      create(:form_submission,
             parent: create(:user, :parent, organisation: user.organisation))
      expect(Pundit.policy_scope!(user, FormSubmission)).to eq(FormSubmission.none)
    end
  end

  context 'when org admin' do
    context 'when submission for own org' do
      let(:user) { create(:user, :org_admin) }
      let(:record) { create(:form_submission, organisation: user.organisation) }

      it_behaves_like 'authorized user'
    end

    context 'when submission for different org' do
      let(:user) { build(:user, :org_admin) }

      it_behaves_like 'unauthorized user'
    end

    it 'scopes to submissions for own org' do
      user = create(:user, :org_admin)
      record = create(:form_submission, organisation: user.organisation)
      create(:form_submission)
      expect(Pundit.policy_scope!(user, FormSubmission)).to contain_exactly(record)
    end
  end

  context 'when school manager' do
    context 'when staff who created submission' do
      let(:user) { create(:user, :school_manager) }
      let(:record) { create(:form_submission, staff: user, organisation: user.organisation) }

      it_behaves_like 'authorized user'
    end

    context 'when they did not create submission' do
      let(:user) { build(:user, :school_manager) }

      it_behaves_like 'unauthorized user'
    end

    it 'scopes to form submissions they created' do
      user = create(:user, :school_manager)
      created_submission = create(:form_submission, staff: user)
      create(:form_submission)
      expect(Pundit.policy_scope!(user, FormSubmission)).to contain_exactly(created_submission)
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      create(:form_submission,
             parent: create(:user, :parent, organisation: user.organisation))
      expect(Pundit.policy_scope!(user, FormSubmission)).to eq(FormSubmission.none)
    end
  end

  context 'when parent' do
    context 'when parent form was created for' do
      let(:user) { create(:user, :parent) }
      let(:record) { create(:form_submission, parent: user) }

      it { is_expected.to authorize_action(:show) }
      it { is_expected.not_to authorize_action(:new) }
      it { is_expected.to authorize_action(:edit) }
      it { is_expected.to authorize_action(:update) }
      it { is_expected.not_to authorize_action(:create) }
      it { is_expected.not_to authorize_action(:destroy) }
    end

    context 'when different parent' do
      let(:user) { build(:user, :parent) }

      it_behaves_like 'unauthorized user'
    end

    it 'scopes to form submissions created for them' do
      parent = create(:user, :parent)
      create(:form_submission, parent:)
      create(:form_submission, organisation: parent.organisation)
      expect(Pundit.policy_scope!(parent, FormSubmission)).to match_array(parent.form_submissions)
    end
  end
end
