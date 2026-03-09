# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeworkHelper do
  Resource = Struct.new(:week, :lesson)
  LessonFiles = Struct.new(:homework_sheet, :homework_answers)
  HomeworkFile = Struct.new(:attached_value) do
    def attached?
      attached_value
    end
  end

  before do
    helper.instance_variable_set(:@plan, create(:plan, start: Date.new(2026, 3, 2)))
    allow(helper).to receive(:url_for).and_return('/homework.pdf')
    allow(helper).to receive(:inline_svg_tag).and_return('')
    allow(helper).to receive(:t).with('.questions').and_return('Questions')
    allow(helper).to receive(:t).with('.answers').and_return('Answers')
  end

  it 'renders one questions/answers button pair per week even with multiple homework files' do
    same_week_resources = [
      Resource.new(1, LessonFiles.new(HomeworkFile.new(true), HomeworkFile.new(false))),
      Resource.new(1, LessonFiles.new(HomeworkFile.new(true), HomeworkFile.new(true)))
    ]

    html = helper.render_homework_rows(same_week_resources)

    expect(html.scan('<tr>').size).to eq(1)
    expect(html.scan('btn btn-secondary').size).to eq(1)
    expect(html.scan('btn btn-danger').size).to eq(1)
  end

  it 'renders separate rows for separate weeks' do
    resources = [
      Resource.new(1, LessonFiles.new(HomeworkFile.new(true), HomeworkFile.new(true))),
      Resource.new(2, LessonFiles.new(HomeworkFile.new(true), HomeworkFile.new(true)))
    ]

    html = helper.render_homework_rows(resources)

    expect(html.scan('<tr>').size).to eq(2)
  end
end
