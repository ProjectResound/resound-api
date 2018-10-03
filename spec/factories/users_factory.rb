FactoryBot.define do
  factory :user do
    nickname { 'Nickname' }
    sequence(:uid) { |n| "abc#{n}"}
  end
end
