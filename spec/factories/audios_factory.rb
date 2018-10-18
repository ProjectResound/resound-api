# frozen_string_literal: true

FactoryBot.define do
  factory :audio do
    sequence(:title)    { |n| "thank you for testing #{n}" }
    sequence(:filename) { |n| "thanks#{n}.wav" }
    uploader { create(:user) }
  end
end
