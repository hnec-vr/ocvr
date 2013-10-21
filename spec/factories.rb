FactoryGirl.define do
  factory :user do
    sequence (:email) { |n| "email#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    country_code "US"
    city "Chicago"

    factory :user_with_blank_password do
      password ""
    end

    factory :verified_user do
      email_verified true

      factory :user_with_nid do
        sequence(:national_id) {|n| n*1000}

        factory :registered_user do
          constituency
          voting_location
        end
      end
    end
  end

  factory :nid_review do
    association :user, :factory => :verified_user
    sequence(:registry_number) {|n| n*1000}
    mother_name "loraine"
  end

  factory :constituency do
    sequence (:name) { |n| "constituency #{n}" }
  end

  factory :voting_location do
    sequence (:en) { |n| "location #{n} en" }
    sequence (:ar) { |n| "location #{n} ar" }
  end
end
