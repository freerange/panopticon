FactoryGirl.define do
  factory :contact do
    sequence(:name)             { |n| "Contact #{n}" }
    sequence(:contactotron_uri) { |n| "http://contactotron.example/contacts/#{n}" }
  end
end
