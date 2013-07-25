module Ticketing
  module CouponsHelper
    def assignment_number(assignment, field = false)
      return "" if assignment.nil?
      assignment.unlimited? ? (field ? "" : "unbegrenzt") : assignment.number
    end
  end
end