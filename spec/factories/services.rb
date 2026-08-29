FactoryBot.define do
  factory :service do
    account { nil }
    name { "MyString" }
    description { "MyText" }
    duration_minutes { 1 }
    price_cents { 1 }
    currency { "MyString" }
    active { false }
    sort_order { 1 }
  end
end
