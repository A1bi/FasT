# frozen_string_literal: true

module DelayedPostProcessing
  extend ActiveSupport::Concern

  class_methods do
    def delay_post_processing(attachment_name)
      define_method("#{attachment_name}=") do |file|
        attachment = public_send(attachment_name)
        attachment.post_processing = false
        attachment.assign(file)
        instance_variable_set("@#{attachment_name}_unprocessed", true)
      end

      after_save do
        next unless instance_variable_get("@#{attachment_name}_unprocessed")

        ProcessAttachmentJob.perform_later(self, attachment_name)
      end
    end
  end
end
