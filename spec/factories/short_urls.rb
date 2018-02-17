FactoryBot.define do
  factory :short_url do
    slug     'sluggy-mc-slugface'
    redirect 'http://www.example.com'

    factory :new_short_url do
      now = Time.now
      created_at now
      updated_at now
    end

    factory :invalid_short_url do
      slug     '.14=+a'
      redirect 'htpt;/foobar.'
    end
  end
end
