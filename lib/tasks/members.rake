namespace :members do
  desc 'generate membership fee debit SEPA xml file'
  task :generate_fee_debit_file, [:path] => [:environment] do
    include ActionView::Helpers::TranslationHelper

    info_keys = %i[name iban creditor_identifier]
    debit_info = info_keys.each_with_object({}) do |key, obj|
      obj[key] = t(key, scope: %i[ticketing payments submissions])
    end

    debit = SEPA::DirectDebit.new(debit_info)
    debit.message_identification = 'FasT/membership-fee/1'

    Members::Member.all.each do |member|
      mandate = member.sepa_mandate
      next if mandate.nil?

      debit.add_transaction(
        name: mandate.debtor_name[0..69],
        iban: mandate.iban,
        amount: member.membership_fee,
        remittance_information: 'Jahresmitgliedsbeitrag für ' + \
                                member.name.full,
        mandate_id: mandate.number(prefixed: true),
        mandate_date_of_signature: mandate.issued_on,
        local_instrument: 'CORE',
        sequence_type: 'RCUR',
        batch_booking: true,
        requested_date: Date.tomorrow
      )
    end

    File.write('/tmp/sepa-membership-fee-inital.xml', debit.to_xml)
  end
end
