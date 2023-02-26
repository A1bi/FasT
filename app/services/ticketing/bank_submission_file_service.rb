# frozen_string_literal: true

module Ticketing
  class BankSubmissionFileService
    def initialize(submission)
      @submission = submission
    end

    def file
      zip_file || debit_xml || transfer_xml
    end

    def file_name
      if zip_file.present?
        prefix = 'sepa'
        extension = 'zip'
      else
        prefix = debit_xml.present? ? :debits : :transfers
        extension = 'xml'
      end
      "#{translated_prefix(prefix)}-#{@submission.id}.#{extension}"
    end

    def file_type
      zip_file.present? ? 'application/zip' : 'application/xml'
    end

    private

    def zip_file
      return unless debit_xml && transfer_xml

      @zip_file ||= begin
        zip = Zip::OutputStream.write_buffer do |f|
          f.put_next_entry("#{translated_prefix(:debits)}.xml")
          f.write(debit_xml)
          f.put_next_entry("#{translated_prefix(:transfers)}.xml")
          f.write(transfer_xml)
        end
        zip.rewind
        zip.sysread
      end
    end

    def debit_xml
      @debit_xml ||= DebitSepaXmlService.new(@submission).xml
    end

    def transfer_xml
      @transfer_xml ||= TransferSepaXmlService.new(@submission).xml
    end

    def translated_prefix(prefix)
      I18n.t("ticketing.bank_submission_file.#{prefix}")
    end
  end
end
