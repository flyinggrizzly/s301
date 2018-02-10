class CreateShortUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :short_urls do |t|
      t.string :slug
      t.text :redirect

      t.timestamps
    end
  end
end
