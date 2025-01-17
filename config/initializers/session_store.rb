# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store,
                                       key: "_#{Rails.application.class.module_parent_name}_session",
                                       secure: Settings.secure_session_cookie?,
                                       same_site: :strict

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# FasT::Application.config.session_store :active_record_store
