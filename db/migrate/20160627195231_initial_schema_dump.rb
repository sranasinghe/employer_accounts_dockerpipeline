class InitialSchemaDump < ActiveRecord::Migration
  def change

    # These are extensions that must be enabled in order to support this database
    enable_extension "hstore"
    enable_extension "plpgsql"
    enable_extension "uuid-ossp"

    create_table "members", id: :uuid, force: :cascade do |t|
      t.text   "first_name"
      t.text   "last_name"
      t.text   "email"
      t.text   "member_id"
      t.string   "password_digest",           limit: 255
      t.string   "date_of_birth"
      t.datetime "created_at",                null: false
      t.datetime "updated_at",                null: false
      t.string   "session_token",             limit: 255
      t.string   "reset_password_token",      limit: 255
      t.datetime "reset_password_expiration"
      t.string   "digest",                    limit: 255
      t.boolean  "termed"
    end
    add_index "members", ["email"], name: "index_members_on_email", unique: true, using: :btree
    add_index "members", ["member_id"], name: "index_members_on_member_id", using: :btree
    add_index "members", ["session_token"], name: "index_members_on_session_token", using: :btree

    create_table "oauth_access_grants", id: :uuid, force: :cascade do |t|
      t.string   "resource_owner_id", null: false
      t.integer  "application_id",    null: false
      t.string   "token",             null: false
      t.integer  "expires_in",        null: false
      t.text     "redirect_uri",      null: false
      t.datetime "created_at",        null: false
      t.datetime "revoked_at"
      t.string   "scopes"
    end
    add_index "oauth_access_grants", ["token"], name: "index_accounts_oauth_access_grants_on_token", unique: true, using: :btree

    create_table "oauth_access_tokens", id: :uuid, force: :cascade do |t|
      t.string   "resource_owner_id"
      t.integer  "application_id"
      t.string   "token",             null: false
      t.string   "refresh_token"
      t.integer  "expires_in"
      t.datetime "revoked_at"
      t.datetime "created_at",        null: false
      t.string   "scopes"
    end
    add_index "oauth_access_tokens", ["refresh_token"], name: "index_accounts_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
    add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_accounts_oauth_access_tokens_on_resource_owner_id", using: :btree
    add_index "oauth_access_tokens", ["token"], name: "index_accounts_oauth_access_tokens_on_token", unique: true, using: :btree

    create_table "oauth_applications", id: :uuid, force: :cascade do |t|
      t.string   "name",         null: false
      t.string   "uid",          null: false
      t.string   "secret",       null: false
      t.text     "redirect_uri", null: false
      t.string   "scopes",       default: "", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    add_index "oauth_applications", ["uid"], name: "index_accounts_oauth_applications_on_uid", unique: true, using: :btree

    create_table "sessions", id: :uuid, force: :cascade do |t|
      t.string   "token",      null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "security_questions", id: :uuid, force: :cascade do |t|
      t.integer  "member_id"
      t.text   "question"
      t.text   "answer"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    add_index "security_questions", ["member_id"], name: "index_security_questions_on_member_id", using: :btree
  end
end
