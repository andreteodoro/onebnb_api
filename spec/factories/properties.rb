FactoryGirl.define do
  factory :property do
    price FFaker.numerify("#.##").to_f
    name FFaker::Lorem.word
    description FFaker::Lorem.paragraph
    accommodation_type { rand(0..2) } # :whole_house, :whole_bedroom :shared_bedroom
    guest_max { rand(1..10) }
    beds { rand(1..10) }
    bedroom { rand(1..10) }
    status { rand(0..3) } # :active, :pending, :inactive, :blocked
    bathroom { rand(1..10) }
    user
    facility
    address
  end
end
