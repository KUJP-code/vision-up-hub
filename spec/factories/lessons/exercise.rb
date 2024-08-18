# frozen_string_literal: true

FactoryBot.define do
  factory :exercise, parent: :lesson do
    title { 'Test Exercise' }
    subtype { 'jumping' }
    type { 'Exercise' }
    level { 'elementary' }
    land_lang_goals { "Goal 1\nGoal 2" }
    sky_lang_goals { "Goal 1\nGoal 2" }
    galaxy_lang_goals { "Goal 1\nGoal 2" }
    materials { "Material 1\nMaterial 2" }
    cardio_and_stretching { "Intro 1\nIntro 2" }
    instructions { "Instruction 1\nInstruction 2" }
    cooldown_and_recap { "Cooldown 1\nRecap 2" }
  end
end
