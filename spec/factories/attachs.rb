FactoryGirl.define do
  factory :attach do
    sequence(:name) { |n| "name#{n}" }
    sequence(:url) { |n| "url#{n}" }
    format "ed2k"
    file_size 0.0
  end
end