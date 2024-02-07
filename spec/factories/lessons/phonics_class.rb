# frozen_string_literal: true

FactoryBot.define do
  factory :phonics_class, parent: :lesson do
    add_difficulty { "Difficult idea 1\nDifficult idea 2" }
    extra_fun { "Extra 1\nExtra 2" }
    instructions { "Test Instructions 1\nTest Instructions 2" }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
    materials { "Material 1\nMaterial 2" }
    notes { "Note 1\nNote 2" }
    title { 'Test Phonics Class' }
    type { 'PhonicsClass' }
  end
end
