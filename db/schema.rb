# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_25_194409) do

  create_table "awards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "project_id"
    t.string "funder_uri"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["funder_uri"], name: "index_awards_on_funder_uri"
    t.index ["project_id"], name: "index_awards_on_project_id"
    t.index ["status"], name: "index_awards_on_status"
  end

  create_table "costs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "data_management_plan_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.float "value"
    t.string "currency_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_management_plan_id"], name: "index_costs_on_data_management_plan_id"
  end

  create_table "data_management_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.string "language", null: false
    t.boolean "ethical_issues"
    t.text "description", size: :long
    t.text "ethical_issues_description", size: :long
    t.text "ethical_issues_report", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "project_id"
    t.index ["project_id"], name: "index_data_management_plans_on_project_id"
  end

  create_table "datasets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "data_management_plan_id"
    t.string "title", null: false
    t.integer "dataset_type", default: 0, null: false
    t.boolean "personal_data"
    t.boolean "sensitive_data"
    t.text "description", size: :long
    t.datetime "publication_date"
    t.string "language"
    t.text "data_quality_assurance", size: :long
    t.text "preservation_statement", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_management_plan_id"], name: "index_datasets_on_data_management_plan_id"
    t.index ["dataset_type"], name: "index_datasets_on_dataset_type"
  end

  create_table "datasets_keywords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.bigint "keyword_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset_id"], name: "index_datasets_keywords_on_dataset_id"
    t.index ["keyword_id"], name: "index_datasets_keywords_on_keyword_id"
  end

  create_table "distributions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.string "format"
    t.float "byte_size"
    t.string "access_url"
    t.string "download_url"
    t.integer "data_access"
    t.datetime "available_until"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset_id"], name: "index_distributions_on_dataset_id"
  end

  create_table "hosts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "distribution_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.boolean "supports_versioning"
    t.string "backup_type"
    t.string "backup_frequency"
    t.string "storage_type"
    t.string "availability"
    t.string "geo_location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["distribution_id"], name: "index_hosts_on_distribution_id"
  end

  create_table "identifiers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "value", null: false
    t.integer "category", default: 0, null: false
    t.string "provenance", null: false
    t.bigint "identifiable_id"
    t.string "identifiable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category"], name: "index_identifiers_on_category"
    t.index ["provenance"], name: "index_identifiers_on_provenance"
  end

  create_table "keywords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "licenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "distribution_id"
    t.string "license_uri", null: false
    t.datetime "start_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["distribution_id"], name: "index_licenses_on_distribution_id"
  end

  create_table "metadata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.string "language", null: false
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset_id"], name: "index_metadata_on_dataset_id"
  end

  create_table "oauth_access_grants", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.text "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true, length: 255
  end

  create_table "oauth_applications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oauth_authorizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "oauth_application_id"
    t.bigint "data_management_plan_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_management_plan_id"], name: "index_oauth_authorizations_on_data_management_plan_id"
    t.index ["oauth_application_id"], name: "index_oauth_authorizations_on_oauth_application_id"
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_organizations_on_name"
  end

  create_table "persons", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "persons_data_management_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "data_management_plan_id"
    t.integer "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["data_management_plan_id"], name: "index_persons_data_management_plans_on_data_management_plan_id"
    t.index ["person_id"], name: "index_persons_data_management_plans_on_person_id"
  end

  create_table "persons_organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "organization_id"
    t.index ["organization_id"], name: "index_persons_organizations_on_organization_id"
    t.index ["person_id"], name: "index_persons_organizations_on_person_id"
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "start_on", null: false
    t.datetime "end_on", null: false
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "data_management_plan_id"
    t.index ["data_management_plan_id"], name: "index_projects_on_data_management_plan_id"
    t.index ["id", "start_on", "end_on"], name: "index_projects_on_id_and_start_on_and_end_on"
  end

  create_table "security_privacy_statements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset_id"], name: "index_security_privacy_statements_on_dataset_id"
  end

  create_table "technical_resources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dataset_id"], name: "index_technical_resources_on_dataset_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", null: false
    t.text "secret"
    t.integer "role", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "orcid"
    t.bigint "organization_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
end
