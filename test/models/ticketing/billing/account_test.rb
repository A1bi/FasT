require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  stores = []
  2.times do
    store = Ticketing::Retail::Store.new
    store.save(validate: false)
    stores << store
  end

  a1 = stores[0].billing_account
  a2 = stores[1].billing_account

  test '1 billing account is present' do
    assert_not_nil(a1, 'Billing account was not created')
    assert_equal(0, a1.balance, 'Balance is not zero')
    assert_equal(0, a1.transfers.length, 'Transfers should be empty')
  end

  test '2 transferring amounts' do
    a1.transfer(a2, 10, :dummy)

    assert_equal(-10, a1.balance, "Sender's balance is wrong")
    assert_equal(10, a2.balance, "Recipient's balance is wrong")

    assert_equal(1, a1.transfers.length, "Sender's transfers wrong")
    assert_equal(1, a2.transfers.length, "Recipient's transfers wrong")

    assert_equal(-10, a1.transfers[0].amount, "Sender's transfer amount wrong")
    assert_equal(:dummy, a1.transfers[0].note_key,
                 "Sender's transfer note key wrong")
    assert_equal(a2, a1.transfers[0].participant,
                 "Sender's transfer participant wrong")

    assert_equal(10, a2.transfers[0].amount,
                 "Recipient's transfer amount wrong")
    assert_equal(:dummy, a2.transfers[0].note_key,
                 "Recipient's transfer note key wrong")
    assert_equal(a1, a2.transfers[0].participant,
                 "Recipient's transfer participant wrong")
    assert_equal(a1.transfers[0], a2.transfers[0].reverse_transfer,
                 "Recipient's transfer reverse transfer wrong")
  end

  test '3 transferring more amounts' do
    a1.transfer(a2, 20, :dummy)

    assert_equal(-30, a1.balance, "Sender's balance is wrong")
    assert_equal(30, a2.balance, "Recipient's balance is wrong")

    a2.transfer(a1, 70, :dummy)

    assert_equal(40, a1.balance, "Sender's balance is wrong")
    assert_equal(-40, a2.balance, "Recipient's balance is wrong")
  end

  test '4 depositing and withdrawing' do
    a1.deposit(10, :dummy)
    assert_equal(50, a1.balance, 'Balance is wrong')
    assert_equal(10, a1.transfers.last.amount,
                 "Sender's deposit transfer amount wrong")
    assert_nil(a1.transfers.last.participant,
               "Sender's deposit transfer participant should be nil")

    a2.deposit(10, :dummy)
    assert_equal(-30, a2.balance, 'Balance is wrong')

    a1.withdraw(30, :dummy)
    assert_equal(20, a1.balance, 'Balance is wrong')

    a2.withdraw(40, :dummy)
    assert_equal(-70, a2.balance, 'Balance is wrong')
  end
end
