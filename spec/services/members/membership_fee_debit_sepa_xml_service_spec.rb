# frozen_string_literal: true

require 'support/xml'

RSpec.describe Members::MembershipFeeDebitSepaXmlService do
  subject { service.xml }

  let(:service) { described_class.new(submission) }
  let(:submission) { create(:membership_fee_debit_submission, payments:) }
  let(:payments) { create_list(:membership_fee_payment, 3, :with_sepa_mandate) }

  before do
    # create another payment not associated with this submission
    # this is expected to make the last payment recurring
    create(:membership_fee_payment, member: payments.last.member)
  end

  def creditor_info(key)
    I18n.t(key, scope: %i[members membership_fee_payments debit_submissions])
  end

  it 'sets the correct creditor information' do
    scope = '//Document/CstmrDrctDbtInitn/GrpHdr/InitgPty'
    expect(subject).to have_xml("#{scope}/Nm", creditor_info(:name))
    expect(subject).to have_xml("#{scope}/Id/OrgId/Othr/Id", /DE/)
    2.times do |i|
      scope = '//Document/CstmrDrctDbtInitn/PmtInf'
      expect(subject).to have_xml("#{scope}[#{i + 1}]/CdtrAcct/Id/IBAN",
                                  creditor_info(:iban))
    end
  end

  it 'adds the correct number of transactions' do
    scope = '//Document/CstmrDrctDbtInitn/PmtInf'
    # first payments
    expect(subject).to have_xml("#{scope}[1]/NbOfTxs", '2')
    # recurring payments
    expect(subject).to have_xml("#{scope}[2]/NbOfTxs", '1')
  end

  it 'sets the recurring debit state correctly' do
    scope = '//Document/CstmrDrctDbtInitn/PmtInf'
    expect(subject).to have_xml("#{scope}[1]/PmtTpInf/SeqTp", 'FRST')
    expect(subject).to have_xml("#{scope}[2]/PmtTpInf/SeqTp", 'RCUR')
  end

  it 'adds transactions with the correct data' do
    payments.each.with_index do |payment, i|
      mandate = payment.member.sepa_mandate
      scope = "//Document/CstmrDrctDbtInitn/PmtInf[#{i / 2 + 1}]" \
              "/DrctDbtTxInf[#{i % 2 + 1}]"

      expect(subject).to have_xml("#{scope}/InstdAmt", format('%.2f', payment.amount))
      expect(subject).to have_xml("#{scope}/Dbtr/Nm", mandate.debtor_name)
      expect(subject).to have_xml("#{scope}/DbtrAcct/Id/IBAN", mandate.iban)
      expect(subject).to have_xml("#{scope}/RmtInf/Ustrd", /Jahresmitgliedsbeitrag.*#{payment.member.name.full}/)
    end
  end
end
