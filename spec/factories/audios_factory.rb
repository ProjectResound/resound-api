FactoryBot.define do
  factory :audio do
    title    { 'thank you for testing' }
    filename { 'thanks.wav' }
    uploader { create(:user) }
  end
end
