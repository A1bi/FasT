class BankMailer < BaseMailer
  def submission(dta)
    attachments["DTAUS0.txt"] = { encoding: "base64", content: Base64.encode64(dta.data) }
    
    mail to: t(:bank_email, scope: [:ticketing, :payments, :submissions])
  end
end
