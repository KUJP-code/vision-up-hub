# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormTemplatePolicy do
  subject(:policy) { described_class.new(user, record) }

  let(:record) { build(:form_template) }

  context 'when admin' do
    let(:user) { build(:user, :admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all form_templates' do
      record.update(organisation_id: user.organisation_id)
      diff_org_template = create(:form_template, organisation_id: create(:organisation).id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to contain_exactly(record, diff_org_template)
    end
  end

  context 'when writer' do
    let(:user) { build(:user, :writer) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      record.update(organisation_id: user.organisation_id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to eq(FormTemplate.none)
    end
  end

  context 'when sales' do
    let(:user) { build(:user, :sales) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      record.update(organisation_id: user.organisation_id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to eq(FormTemplate.none)
    end
  end

  context 'when OrgAdmin' do
    let(:user) { build(:user, :org_admin) }

    it_behaves_like 'authorized user'

    it 'scopes to all templates for org' do
      user.save
      record.update(organisation_id: user.organisation_id)
      create(:form_template, organisation_id: create(:organisation).id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to contain_exactly(record)
    end
  end

  context 'when school manager' do
    let(:user) { build(:user, :school_manager) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      record.update(organisation_id: user.organisation_id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to eq(FormTemplate.none)
    end
  end

  context 'when teacher' do
    let(:user) { build(:user, :teacher) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      record.update(organisation_id: user.organisation_id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to eq(FormTemplate.none)
    end
  end

  context 'when parent' do
    let(:user) { build(:user, :parent) }

    it_behaves_like 'unauthorized user'

    it 'scopes to nothing' do
      record.update(organisation_id: user.organisation_id)
      expect(Pundit.policy_scope!(user, FormTemplate)).to eq(FormTemplate.none)
    end
  end
end
