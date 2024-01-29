# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    initialize_with { type.constantize.new }
    organisation
    name { 'Test User' }
    email { 'pC9Xp@example.com' }
    password { 'passwordpassword' }
    type { 'Teacher' }

    trait :admin do
      type { 'Admin' }
    end

    trait :org_admin do
      type { 'OrgAdmin' }
    end

    trait :sales do
      type { 'Sales' }
    end

    trait :school_manager do
      type { 'SchoolManager' }
    end

    trait :teacher do
      type { 'Teacher' }
    end

    trait :writer do
      type { 'Writer' }
    end
  end
end
