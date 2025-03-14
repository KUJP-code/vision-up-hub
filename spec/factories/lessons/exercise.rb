# frozen_string_literal: true

FactoryBot.define do
  factory :exercise, parent: :lesson do
    title { 'Test Exercise' }
    intro { 'Test Intro' }
    subtype { :aerobics }
    type { 'Exercise' }
    level { 'kindy' }
    land_lang_goals { "Goal 1\nGoal 2" }
    sky_lang_goals { "Goal 1\nGoal 2" }
    galaxy_lang_goals { "Goal 1\nGoal 2" }
    materials { "Material 1\nMaterial 2" }
    instructions { "Instruction 1\nInstruction 2" }
  end
end
