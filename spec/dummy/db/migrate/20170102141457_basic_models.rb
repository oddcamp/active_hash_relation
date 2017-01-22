class BasicModels < ActiveRecord::Migration[5.0]
  def change
    create_table "microposts", force: :cascade do |t|
      t.text     "content", null: false
      t.integer  "user_id", null: false
      t.integer  "likes", null: false, default: 0
      t.integer  "reposts", null: false, default: 0
      t.integer  "status", null: false, default: 0

      t.timestamps null: false

      t.index ["user_id"], name: "index_microposts_on_user_id", using: :btree
    end

    create_table "relationships", force: :cascade do |t|
      t.integer  "follower_id"
      t.integer  "followed_id"

      t.timestamps null: false

      t.index ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
      t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
      t.index ["follower_id"], name: "index_relationships_on_follower_id", using: :btree
    end

    create_table "users", force: :cascade do |t|
      t.string   "name"
      t.string   "email", null: false
      t.boolean  "admin", default: false
      t.boolean  "verified", default: false
      t.string   "token", null: false
      t.integer  "microposts_count", default: 0, null: false
      t.integer  "followers_count", default: 0, null: false
      t.integer  "followings_count", default: 0, null: false

      t.timestamps null: false

      t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    end

    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :country
      t.integer :user_id

      t.timestamps
      t.index ["user_id"], name: "index_addresses_on_user_id", unique: true, using: :btree
    end

    add_foreign_key "microposts", "users"
  end
end
