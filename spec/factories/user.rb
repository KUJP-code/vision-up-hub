# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    initialize_with { type.constantize.new }
    organisation
    name { 'Test User' }
    sequence(:email) { |n| "test_user#{n}@example.com" }
    password { 'passwordpassword' }
    type { 'OrgAdmin' }

    trait :admin do
      organisation factory: :organisation, name: 'KidsUP'
      type { 'Admin' }
    end

    trait :org_admin do
      type { 'OrgAdmin' }
    end

    trait :sales do
      organisation factory: :organisation, name: 'KidsUP'
      type { 'Sales' }
    end

    trait :school_manager do
      type { 'SchoolManager' }
    end

    trait :teacher do
      school
      type { 'Teacher' }
    end

    trait :writer do
      organisation factory: :organisation, name: 'KidsUP'
      type { 'Writer' }
    end
  end
end
