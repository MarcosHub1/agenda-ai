FactoryBot.define do
  factory :professional do
    account { nil }
    user { nil }
    name { "MyString" }
    email { "MyString" }
    avatar_url { "MyString" }
    active { false }
  end
end
