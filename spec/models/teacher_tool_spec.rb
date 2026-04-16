# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeacherTool do
  it 'has a valid factory' do
    expect(build(:teacher_tool)).to be_valid
  end

  it 'requires a unique title per organisation' do
    organisation = create(:organisation)
    create(:teacher_tool, organisation:, title: 'Timer')

    duplicate = build(:teacher_tool, organisation:, title: 'Timer')

    expect(duplicate).not_to be_valid
  end

  it 'requires an embed url for video tools' do
    tool = build(:teacher_tool, embed_url: nil)

    expect(tool).not_to be_valid
    expect(tool.errors[:embed_url]).not_to be_empty
  end

  it 'does not require an embed url for external tools' do
    tool = build(:teacher_tool, :external, embed_url: nil)

    expect(tool).to be_valid
  end
end
