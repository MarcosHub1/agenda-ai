FactoryBot.define do
  factory :account do
    name { "MyString" }
    slug { "MyString" }
    logo_url { "MyString" }
    timezone { "MyString" }
    currency { "MyString" }
    settings { "" }
    status { 1 }
  end
end
