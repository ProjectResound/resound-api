# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    nickname { 'Nickname' }
    sequence(:uid) { |n| "abc#{n}" }
  end
end
