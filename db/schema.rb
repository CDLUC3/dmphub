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

ActiveRecord::Schema.define(version: 2021_03_19_184054) do

  create_table "affiliations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "alternate_names"
    t.json "attrs", null: false
    t.text "types"
    t.bigint "provenance_id"
    t.index ["name"], name: "index_affiliations_on_name"
    t.index ["provenance_id"], name: "index_affiliations_on_provenance_id"
  end

  create_table "alterations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "alterable_id", null: false
    t.string "alterable_type", default: "", null: false
    t.text "change_log", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id", null: false
    t.index ["alterable_id", "alterable_type"], name: "index_alterations_on_alterable_id_and_alterable_type"
    t.index ["provenance_id"], name: "index_alterations_on_provenance_id"
  end

  create_table "api_client_authorizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "api_client_id", null: false
    t.integer "authorizable_id", null: false
    t.string "authorizable_type", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_client_id"], name: "index_api_client_authorizations_on_api_client_id"
  end

  create_table "api_client_histories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "api_client_id", null: false
    t.bigint "data_management_plan_id", null: false
    t.integer "change_type"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_client_id"], name: "index_api_client_histories_on_api_client_id"
    t.index ["data_management_plan_id"], name: "index_api_client_histories_on_data_management_plan_id"
  end

  create_table "api_client_permissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "api_client_id", null: false
    t.integer "permission", null: false
    t.text "rules"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["api_client_id"], name: "index_api_client_permissions_on_api_client_id"
  end

  create_table "api_clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "homepage"
    t.string "contact_name"
    t.string "contact_email", null: false
    t.string "client_id", null: false
    t.string "client_secret", null: false
    t.date "last_access"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_api_clients_on_name"
  end

  create_table "citations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "identifier_id", null: false
    t.bigint "provenance_id", null: false
    t.integer "object_type", default: 0, null: false
    t.text "citation_text"
    t.json "original_json"
    t.datetime "retrieved_on", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["identifier_id"], name: "index_citations_on_identifier_id"
    t.index ["object_type"], name: "index_citations_on_object_type"
    t.index ["provenance_id"], name: "index_citations_on_provenance_id"
    t.index ["retrieved_on"], name: "index_citations_on_retrieved_on"
  end

  create_table "contributors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "affiliation_id"
    t.bigint "provenance_id"
    t.index ["affiliation_id"], name: "index_contributors_on_affiliation_id"
    t.index ["provenance_id"], name: "index_contributors_on_provenance_id"
  end

  create_table "contributors_data_management_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "contributor_id"
    t.bigint "data_management_plan_id"
    t.integer "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["contributor_id"], name: "index_contributors_data_management_plans_on_contributor_id"
    t.index ["data_management_plan_id"], name: "index_contribs_dmps"
    t.index ["provenance_id"], name: "index_contributors_data_management_plans_on_provenance_id"
  end

  create_table "costs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "data_management_plan_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.float "value"
    t.string "currency_code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["data_management_plan_id"], name: "index_costs_on_data_management_plan_id"
    t.index ["provenance_id"], name: "index_costs_on_provenance_id"
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
    t.bigint "provenance_id"
    t.datetime "version"
    t.integer "source_privacy", default: 0
    t.index ["project_id"], name: "index_data_management_plans_on_project_id"
    t.index ["provenance_id"], name: "index_data_management_plans_on_provenance_id"
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
    t.bigint "provenance_id"
    t.index ["data_management_plan_id"], name: "index_datasets_on_data_management_plan_id"
    t.index ["dataset_type"], name: "index_datasets_on_dataset_type"
    t.index ["provenance_id"], name: "index_datasets_on_provenance_id"
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
    t.bigint "provenance_id"
    t.bigint "host_id"
    t.index ["dataset_id"], name: "index_distributions_on_dataset_id"
    t.index ["host_id"], name: "index_distributions_on_host_id"
    t.index ["provenance_id"], name: "index_distributions_on_provenance_id"
  end

  create_table "fundings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "project_id"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "affiliation_id"
    t.bigint "provenance_id"
    t.index ["affiliation_id"], name: "index_funding_on_organization_id"
    t.index ["project_id"], name: "index_funding_on_project_id"
    t.index ["provenance_id"], name: "index_fundings_on_provenance_id"
    t.index ["status"], name: "index_funding_on_status"
  end

  create_table "fundings_affiliations", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "funding_id"
    t.bigint "affiliation_id"
    t.index ["affiliation_id"], name: "index_fundings_affiliations_on_affiliation_id"
    t.index ["funding_id"], name: "index_fundings_affiliations_on_funding_id"
  end

  create_table "hosts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
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
    t.text "certified_with"
    t.text "pid_system"
    t.bigint "provenance_id"
    t.index ["provenance_id"], name: "index_hosts_on_provenance_id"
  end

  create_table "identifiers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "value", null: false
    t.integer "category", default: 0, null: false
    t.bigint "identifiable_id"
    t.string "identifiable_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "descriptor", default: 0
    t.bigint "provenance_id"
    t.index ["category"], name: "index_identifiers_on_category"
    t.index ["provenance_id"], name: "index_identifiers_on_provenance_id"
  end

  create_table "keywords", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "value", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "licenses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "distribution_id"
    t.string "license_ref", null: false
    t.datetime "start_date", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["distribution_id"], name: "index_licenses_on_distribution_id"
    t.index ["provenance_id"], name: "index_licenses_on_provenance_id"
  end

  create_table "metadata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.string "language", null: false
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["dataset_id"], name: "index_metadata_on_dataset_id"
    t.index ["provenance_id"], name: "index_metadata_on_provenance_id"
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "start_on"
    t.datetime "end_on"
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["id", "start_on", "end_on"], name: "index_projects_on_id_and_start_on_and_end_on"
    t.index ["provenance_id"], name: "index_projects_on_provenance_id"
  end

  create_table "provenances", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_provenances_on_name"
  end

  create_table "security_privacy_statements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.string "title", null: false
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "provenance_id"
    t.index ["dataset_id"], name: "index_security_privacy_statements_on_dataset_id"
    t.index ["provenance_id"], name: "index_security_privacy_statements_on_provenance_id"
  end

  create_table "technical_resources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "dataset_id"
    t.text "description", size: :long
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "title", null: false
    t.bigint "provenance_id"
    t.index ["dataset_id"], name: "index_technical_resources_on_dataset_id"
    t.index ["provenance_id"], name: "index_technical_resources_on_provenance_id"
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
    t.bigint "affiliation_id"
    t.index ["affiliation_id"], name: "index_users_on_affiliation_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
