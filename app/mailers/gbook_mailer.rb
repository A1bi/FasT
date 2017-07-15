class GbookMailer < BaseMailer
  def new_entry(entry)
    @entry = entry
    mail to: "info@theater-kaisersesch.de"
  end
end
