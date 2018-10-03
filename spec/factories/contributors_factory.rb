FactoryBot.define do
  factory :contributor do
    sequence(:name) { |n| "Contributor #{n}" }
  end
end
