class ArticleTest < ActiveSupport::TestCase
  stores = []
  2.times do
    store = Ticketing::Retail::Store.new
    store.save(validate: false)
    stores << store
  end

  a1 = stores[0].billing_account
  a2 = stores[1].billing_account

  test "billing account is present" do
    assert_not_nil(a1, "Billing account was not created")
    assert_equal(0, a1.balance, "Balance is not zero")
    assert_equal(0, a1.transfers.count, "Transfers should be empty")
  end

  test "transferring amounts" do
    a1.transfer(a2, 10)

    assert_equal(-10, a1.balance, "Sender's balance is wrong")
    assert_equal(10, a2.balance, "Recipient's balance is wrong")

    assert_equal(1, a1.transfers.count, "Sender's transfers wrong")
    assert_equal(1, a2.transfers.count, "Recipient's transfers wrong")

    assert_equal(-10, a1.transfers[0].amount, "Sender's transfer amount wrong")
    assert_equal(a2, a1.transfers[0].recipient, "Sender's transfer recipient wrong")

    assert_equal(10, a2.transfers[0].amount, "Recipient's transfer amount wrong")
    assert_equal(a1, a2.transfers[0].recipient, "Recipient's transfer recipient wrong")
    assert_equal(a1.transfers[0], a2.transfers[0].reverse_transfer, "Recipient's transfer reverse transfer wrong")
  end

  test "transferring more amounts" do
    a1.transfer(a2, 20)

    assert_equal(-30, a1.balance, "Sender's balance is wrong")
    assert_equal(30, a2.balance, "Recipient's balance is wrong")

    a2.transfer(a1, 70)

    assert_equal(40, a1.balance, "Sender's balance is wrong")
    assert_equal(-40, a2.balance, "Recipient's balance is wrong")
  end
end
