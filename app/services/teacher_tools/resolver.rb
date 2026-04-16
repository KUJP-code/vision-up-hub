# frozen_string_literal: true

module TeacherTools
  Tool = Struct.new(
    :id,
    :record,
    :title,
    :description,
    :kind,
    :url,
    :embed_url,
    :duration_label,
    :position,
    keyword_init: true
  )

  class Resolver
    def self.call(organisation:)
      new(organisation:).call
    end

    def initialize(organisation:)
      @organisation = organisation
    end

    def call
      organisation.teacher_tools
                  .includes(cover_image_attachment: :blob)
                  .select(&:active?)
                  .sort_by { |tool| [tool.position || 0, tool.title.to_s] }
                  .map { |tool| build_tool(tool) }
    end

    private

    attr_reader :organisation

    def build_tool(tool)
      Tool.new(
        id: tool.id,
        record: tool,
        title: tool.title,
        description: tool.description,
        kind: tool.kind,
        url: tool.url,
        embed_url: tool.effective_embed_url,
        duration_label: tool.duration_label,
        position: tool.position
      )
    end
  end
end
