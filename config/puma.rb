# frozen_string_literal: true

bind "tcp://[::]:#{ENV.fetch('PORT', 3000)}"

threads 0, ENV.fetch('RAILS_MAX_THREADS', 5)
