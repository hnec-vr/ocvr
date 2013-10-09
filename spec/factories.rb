FactoryGirl.define do
  factory :user do
    sequence (:email) { |n| "email#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    country_code "US"
    city "Chicago"
  end
end
