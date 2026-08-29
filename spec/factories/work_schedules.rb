FactoryBot.define do
  factory :work_schedule do
    professional { nil }
    day_of_week { 1 }
    start_time { "2026-08-29 11:05:59" }
    end_time { "2026-08-29 11:05:59" }
    break_start { "2026-08-29 11:05:59" }
    break_end { "2026-08-29 11:05:59" }
    enabled { false }
  end
end
