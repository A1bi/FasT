#!/usr/bin/env rake
# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

# disable redundant yarn install (Rails and Webpacker both trigger it)
Rake::Task['webpacker:yarn_install'].clear
