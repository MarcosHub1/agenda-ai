FactoryBot.define do
  factory :client do
    account { nil }
    name { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    notes { "MyText" }
  end
end
