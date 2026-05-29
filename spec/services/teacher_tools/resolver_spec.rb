# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeacherTools::Resolver do
  describe '.call' do
    it 'returns base set tools in position order' do
      organisation = create(:organisation)
      later = create(:teacher_tool, organisation:, position: 2, title: 'Later Tool')
      earlier = create(:teacher_tool, organisation:, position: 1, title: 'Earlier Tool')

      resolved = described_class.call(organisation:)

      expect(resolved.map(&:id)).to eq([earlier.id, later.id])
    end

    it 'ignores inactive tools' do
      organisation = create(:organisation)
      active = create(:teacher_tool, organisation:, title: 'Active Tool', position: 1)
      create(:teacher_tool, organisation:, title: 'Inactive Tool', active: false, position: 2)

      resolved = described_class.call(organisation:)

      expect(resolved.map(&:title)).to eq([active.title])
    end
  end
end
