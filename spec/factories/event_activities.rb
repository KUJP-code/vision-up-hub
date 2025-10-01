FactoryBot.define do
  factory :event_activity, parent: :lesson, class: 'EventActivity' do
    title { "Event #{SecureRandom.hex(4)}" }
  end
end
