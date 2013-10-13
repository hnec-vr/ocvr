FactoryGirl.define do
  factory :user do
    sequence (:email) { |n| "email#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    country_code "US"
    city "Chicago"

    factory :verified_user do
      email_verified true
    end
  end
end
