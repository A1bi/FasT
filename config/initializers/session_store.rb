# Be sure to restart your server when you modify this file.

FasT::Application.config.session_store :cookie_store, key: '_FasT_session', secure: (CONFIG.has_key?(:secure_session_cookie) ? CONFIG[:secure_session_cookie] : true)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# FasT::Application.config.session_store :active_record_store
