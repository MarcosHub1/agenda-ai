FactoryBot.define do
  factory :schedule_exception do
    professional { nil }
    exception_date { "2026-08-29" }
    is_blocked { false }
    start_time { "2026-08-29 11:06:00" }
    end_time { "2026-08-29 11:06:00" }
    reason { "MyString" }
  end
end
