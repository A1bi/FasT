# frozen_string_literal: true

module StaticHelper
  def events_for_ensemble(ensemble)
    Ticketing::Event.where("info->>'ensemble' = ?", ensemble)
                    .including_ticketing_disabled.archived
                    .includes(:dates, :location).ordered_by_dates(:desc)
  end
end
