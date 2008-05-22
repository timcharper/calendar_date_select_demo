class CreateListings < ActiveRecord::Migration
  def self.up
    create_table :listings do |t|
      t.string :name
      t.datetime :created_on
      t.datetime :last_follow_up_at
      t.timestamps
    end
  end

  def self.down
    drop_table :listings
  end
end
