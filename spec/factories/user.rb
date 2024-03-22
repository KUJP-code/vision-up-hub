# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    initialize_with { type.constantize.new }
    organisation
    sequence(:name) { |n| "Test User #{n}" }
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
      type { 'Teacher' }
    end

    trait :writer do
      organisation factory: :organisation, name: 'KidsUP'
      type { 'Writer' }
    end

    trait :parent do
      type { 'Parent' }
    end
  end
end
