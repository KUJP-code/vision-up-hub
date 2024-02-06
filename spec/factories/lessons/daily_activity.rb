# frozen_string_literal: true

FactoryBot.define do
  factory :daily_activity, parent: :lesson do
    extra_fun { "Extra fun 1\nExtra fun 2" }
    instructions { "Instruction 1\nInstruction 2" }
    intro { "Intro 1\nIntro 2" }
    large_groups { "Group 1\nGroup 2" }
    links { "Example link:http://example.com\nSeasonal:http://example.com/seasonal" }
    materials { "Material 1\nMaterial 2" }
    notes { "Note 1\nNote 2" }
    steps { "Step 1\nStep 2" }
    subtype { :discovery }
    title { 'Test Daily Activity' }
    type { 'DailyActivity' }
  end
end
