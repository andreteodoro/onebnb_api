FactoryGirl.define do
  factory :transaction do
    user
    reservation
    price FFaker.numerify("#.##").to_f
  end
end
