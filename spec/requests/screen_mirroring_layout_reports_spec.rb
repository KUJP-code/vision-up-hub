# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Local lesson layout diagnostics' do
  let(:report_path) { Rails.root.join('tmp/ai-sensei-layout-reports-test.jsonl') }
  after { FileUtils.rm_f(report_path) }

  it 'accepts geometry from an event account and discards unrelated fields' do
    sign_in create(:user, :ai_sensei)
    post ai_sensei_layout_report_path, as: :json, params: {
      report: { event: 'open', private_value: 'discard', dimensions: { inner_height: 700 },
                elements: [{ name: 'body', top: 0, margin_top: '0px' }] }
    }
    expect(response).to have_http_status(:no_content)
    report = JSON.parse(File.readlines(report_path).last)
    expect(report).to include('event' => 'open', 'dimensions' => { 'inner_height' => 700 })
    expect(report['elements']).to eq([{ 'name' => 'body', 'top' => 0, 'margin_top' => '0px' }])
    expect(report).not_to have_key('private_value')
  end

  it 'is unavailable outside local environments' do
    sign_in create(:user, :admin)
    allow(Rails.env).to receive(:local?).and_return(false)
    post ai_sensei_layout_report_path, as: :json, params: { report: { event: 'open' } }
    expect(response).to have_http_status(:not_found)
    expect(File.exist?(report_path)).to be false
  end

  it 'rejects oversized reports' do
    sign_in create(:user, :admin)
    post ai_sensei_layout_report_path, as: :json, params: { report: { event: 'x' * 16_384 } }
    expect(response).to have_http_status(413)
  end

  it 'does not accept reports from other account types' do
    sign_in create(:user, :teacher)
    post ai_sensei_layout_report_path, as: :json, params: { report: { event: 'open' } }
    expect(response).to have_http_status(:not_found)
  end
end
