FactoryGirl.define do
  factory :reservation do
    property_id 1
    user_id 1
    checkin_date "2017-01-30"
    checkout_date "2017-01-30"
    status 1
  end
end
