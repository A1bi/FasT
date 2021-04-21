# frozen_string_literal: true

class MoveTicketingCouponAmountToBillingAccount < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        coupons = execute(
          'SELECT id, amount FROM ticketing_coupons WHERE amount > 0'
        )

        coupons.each do |coupon|
          account_id = insert <<-SQL.squish # rubocop:disable Rails/SkipsModelValidations
            INSERT INTO ticketing_billing_accounts
              (balance, billable_type, billable_id, created_at, updated_at)
            VALUES (#{coupon['amount']}, 'Ticketing::Coupon', #{coupon['id']},
                    '#{coupon['created_at']}', '#{coupon['created_at']}')
          SQL

          execute <<-SQL.squish
            INSERT INTO ticketing_billing_transactions
              (amount, note_key, account_id, created_at, updated_at)
            VALUES (#{coupon['amount']}, 'purchased_coupon', #{account_id},
                    '#{coupon['created_at']}', '#{coupon['created_at']}')
          SQL
        end
      end

      dir.down do
        accounts = execute <<-SQL.squish
          SELECT id, billable_id, balance
          FROM ticketing_billing_accounts
          WHERE billable_type = 'Ticketing::Coupon'
        SQL

        accounts.each do |account|
          execute <<-SQL.squish
            UPDATE ticketing_coupons
            SET amount = #{account['balance']}
            WHERE id = #{account['billable_id']}
          SQL

          execute <<-SQL.squish
            DELETE FROM ticketing_billing_transactions
            WHERE account_id = #{account['id']}
          SQL

          execute <<-SQL.squish
            DELETE FROM ticketing_billing_accounts
            WHERE id = #{account['id']}
          SQL
        end
      end
    end

    remove_column :ticketing_coupons, :amount, :decimal, null: false, default: 0
  end
end
