# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CSV exports' do
  let(:admin) { create(:user, :admin) }
  let(:school) { create(:school, organisation: admin.organisation) }
  let(:student) do
    create(:student, school:, organisation: admin.organisation,
                     name: '山田 太郎', en_name: 'Taro Yamada', student_id: '001234')
  end
  let(:test) do
    create(:test, questions: "Listening: 1, 2, 3, 4\nReading: 1, 2, 3\nWriting: 2, 3, 4, 6")
  end

  before { sign_in admin }

  it 'links to detailed test exports from the general CSV exports page' do
    get csv_exports_path

    document = Nokogiri::HTML(response.body)
    link = document.at_xpath('//a[normalize-space()="Test Result"]')
    expect(link['href']).to eq(new_csv_export_path(model: 'TestResult'))
  end

  it 'downloads the original detailed format through the Tests tab and test picker' do
    create(:test_result, student:, test:, basics: 2, prev_level: :sky_one,
                         new_level: :sky_two, reason: 'Ready, with support',
                         answers: { listening: [1, 2, 3, 4], reading: [1, 2, 3], writing: [2, 3, 4, 6] })

    get csv_exports_path(tab: 'tests')
    document = Nokogiri::HTML(response.body)
    picker_link = document.at_xpath('//a[normalize-space()="Export results by test"]')
    expect(picker_link).to be_present

    get picker_link['href']
    document = Nokogiri::HTML(response.body)
    test_link = document.at_xpath('//a[normalize-space()="Test test"]')
    expect(test_link).to be_present

    get test_link['href']

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq('text/csv')
    expect(response.headers['Content-Disposition']).to include('attachment')
    rows = CSV.parse(response.body.force_encoding('UTF-8'))
    expect(rows.first).to eq(%w[name en_name student_id grade school current_level name_date
                                listening_a listening_b listening_c listening_d
                                reading_a reading_b reading_c
                                writing_a writing_b writing_c writing_d new_level reason])
    expected_row = [student.name, student.en_name, '001234', student.grade, school.name, 'Sky One', '2',
                    '1', '2', '3', '4', '1', '2', '3', '2', '3', '4', '6', 'Sky Two', 'Ready, with support']
    expect(rows.drop(1)).to eq([expected_row])
  end

  it 'keeps scores, levels and reasons in their columns when some answers are missing' do
    create(:test_result, student:, test:, reason: 'Incomplete scores',
                         answers: { listening: [1], reading: [1, 2, 3] })

    get csv_export_path(0, model: 'TestResult', test_id: test.id)

    rows = CSV.parse(response.body, headers: true)
    row = rows.first
    expect(row.fields.size).to eq(rows.headers.size)
    expect(row.to_h).to include('listening_a' => '1', 'listening_b' => nil,
                                'listening_c' => nil, 'listening_d' => nil,
                                'reading_a' => '1', 'reading_b' => '2', 'reading_c' => '3',
                                'writing_a' => nil, 'writing_d' => nil,
                                'new_level' => 'Galaxy One', 'reason' => 'Incomplete scores')
  end

  it 'limits detailed exports to the selected test and current organisation' do
    create(:test_result, student:, test:, reason: 'Selected result')
    create(:test_result, student:, reason: 'Another test')
    create(:test_result, test:, reason: 'Another organisation')

    get csv_export_path(0, model: 'TestResult', test_id: test.id)

    rows = CSV.parse(response.body, headers: true)
    expect(rows.size).to eq(1)
    expect(rows.first['student_id']).to eq('001234')
    expect(rows.first['reason']).to eq('Selected result')
  end
end
