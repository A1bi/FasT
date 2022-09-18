# frozen_string_literal: true

module Ticketing
  class BankSubmissionZipService
    def initialize(submission)
      @submission = submission
    end

    def zip
      zip = Zip::OutputStream.write_buffer do |f|
        if debit_xml
          f.put_next_entry('debits.xml')
          f.write(debit_xml)
        end
        if transfer_xml
          f.put_next_entry('transfers.xml')
          f.write(transfer_xml)
        end
      end
      zip.rewind
      zip.sysread
    end

    private

    def debit_xml
      @debit_xml ||= DebitSepaXmlService.new(@submission).xml
    end

    def transfer_xml
      @transfer_xml ||= TransferSepaXmlService.new(@submission).xml
    end
  end
end
