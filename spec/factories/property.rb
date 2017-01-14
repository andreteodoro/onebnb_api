FactoryGirl.define do
  timestamp = DateTime.parse(2.weeks.ago.to_s).to_time.strftime("%F %T")

  factory :property, class: Api::V1::Property do
    title          FFaker::Name.name
    description    FFaker::Name.name
    created_at     timestamp
    updated_at     timestamp
  end
end
