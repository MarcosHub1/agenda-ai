FactoryBot.define do
  factory :appointment do
    account { nil }
    professional { nil }
    service { nil }
    client { nil }
    starts_at { "2026-08-29 11:06:02" }
    ends_at { "2026-08-29 11:06:02" }
    status { 1 }
    price_cents { 1 }
    cancellation_reason { "MyString" }
    notes { "MyText" }
    metadata { "" }
  end
end
