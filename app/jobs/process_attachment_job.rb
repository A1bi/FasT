# frozen_string_literal: true

class ProcessAttachmentJob < ApplicationJob
  def perform(record, attachment_name)
    record.public_send(attachment_name).reprocess!
  end
end
