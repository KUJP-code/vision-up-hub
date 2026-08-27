# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resources' do
  let(:admin) { create(:user, :admin) }

  before { sign_in admin }

  describe 'GET /tutorials' do
    it 'shows the section picker before categories when multiple sections exist' do
      kindy = create(:tutorial_section, title: 'Kindy')
      elementary = create(:tutorial_section, title: 'Elementary')
      create(:tutorial_category, title: 'Kindy Training', tutorial_section: kindy)
      create(:tutorial_category, title: 'Elementary Training', tutorial_section: elementary)

      get tutorials_path

      expect(response.body).to include('Kindy', 'Elementary')
      expect(response.body).not_to include('Kindy Training', 'Elementary Training')
      expect(response.body).to include('md:justify-center', 'basis-1/3', 'text-3xl')
    end

    it 'skips the section picker when only one effective section exists' do
      section = create(:tutorial_section, title: 'Training')
      create(:tutorial_category, title: 'Teacher Basics', tutorial_section: section)

      get tutorials_path

      expect(response.body).to include('Teacher Basics')
      expect(response.body).not_to include('min-h-64')
    end

    it 'puts unassigned categories in the built-in Others section' do
      create(:tutorial_section, title: 'Training')
      create(:tutorial_category, title: 'Unsorted Resource')

      get tutorials_path
      expect(response.body).to include('Others')
      expect(response.body).to include('Others example image')
      expect(response.body).not_to include('Unsorted Resource')

      get tutorials_path(section: 'others')
      expect(response.body).to include('Unsorted Resource')
    end
  end

  describe 'GET /tutorials/:id video item' do
    it 'renders the embedded video at the full modal size' do
      tutorial = create(:tutorial_category, items: [{
                          'kind' => 'video',
                          'title' => 'Training video',
                          'url' => 'https://www.youtube.com/watch?v=abcdefghijk'
                        }])

      get tutorial_path(tutorial, item: 0)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('flex items-center justify-center h-full w-full p-4')
      iframe = response.parsed_body.at_css('iframe')
      expect(iframe['class'].split).to contain_exactly('w-full', 'h-full')
    end
  end

  describe 'POST /tutorials' do
    it 'creates the card and multiple item types through one endpoint' do
      expect do
        post tutorials_path, params: { tutorial_category: {
          title: 'Help card',
          items_attributes: {
            '0' => { kind: 'link', title: 'Guide', url: 'https://example.com/guide' },
            '1' => { kind: 'faq', title: 'How?', body: 'Like this.' }
          }
        } }
      end.to change(TutorialCategory, :count).by(1)

      expect(TutorialCategory.last.items.pluck('kind')).to contain_exactly('link', 'faq')
    end
  end

  describe 'drag reordering' do
    it 'reorders sections without exposing position inputs' do
      first = create(:tutorial_section, position: 0)
      second = create(:tutorial_section, position: 1)

      get new_tutorial_section_path
      expect(response.body).not_to include('tutorial_section_position')

      patch reorder_tutorial_sections_path,
            params: { tutorial_section_ids: [second.id, first.id] }

      expect(response).to have_http_status(:no_content)
      expect(first.reload.position).to eq(1)
      expect(second.reload.position).to eq(0)
    end

    it 'reorders categories only within the selected section' do
      section = create(:tutorial_section)
      first = create(:tutorial_category, tutorial_section: section, position: 0)
      second = create(:tutorial_category, tutorial_section: section, position: 1)

      patch reorder_tutorials_path,
            params: { tutorial_section_id: section.id,
                      tutorial_ids: [second.id, first.id] }

      expect(response).to have_http_status(:no_content)
      expect(first.reload.position).to eq(1)
      expect(second.reload.position).to eq(0)
    end
  end
end
