class ShortUrl < ApplicationRecord
  validates :slug, presence:   true,
                   uniqueness: { case_sensitive: false },
                   length:     { maximum: 255 },
                   slug:       true
  validates :redirect, presence:      true,
                       url:           true,
                       safe_redirect: true
end
