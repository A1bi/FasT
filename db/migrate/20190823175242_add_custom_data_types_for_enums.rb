# frozen_string_literal: true

class AddCustomDataTypesForEnums < ActiveRecord::Migration[6.0]
  def up
    migrate_integer_to_enum(:newsletter_newsletters, :status, :newsletter_newsletter_status, Newsletter::Newsletter.statuses, :draft)
    migrate_integer_to_enum(:ticketing_check_ins, :medium, :ticketing_check_in_medium, Ticketing::CheckIn.media)
    migrate_integer_to_enum(:ticketing_orders, :pay_method, :ticketing_pay_method, Ticketing::Web::Order.pay_methods)

    migrate_integer_to_enum(:ticketing_orders, :type, :ticketing_order_type, %i[Ticketing::Web::Order Ticketing::Retail::Order Ticketing::BoxOffice::Order])
    migrate_integer_to_enum(:users, :type, :user_type, %i[User Members::Member])
  end

  def down
    rollback_enum(:newsletter_newsletters, :status, :newsletter_newsletter_status, 0)
    rollback_enum(:ticketing_check_ins, :medium, :ticketing_check_in_medium)
    rollback_enum(:ticketing_orders, :pay_method, :ticketing_pay_method)

    rollback_enum(:ticketing_orders, :type, :ticketing_order_type)
    rollback_enum(:users, :type, :user_type)
  end

  private

  def migrate_integer_to_enum(table_name, column_name, enum_name, enum, default = nil)
    enum = enum.map { |val| [val, val] }.to_h if column_name == :type

    if default
      execute <<-SQL.squish
        ALTER TABLE #{table_name} ALTER COLUMN #{column_name} DROP DEFAULT;
      SQL
    end

    execute <<-SQL.squish
      CREATE TYPE #{enum_name} AS ENUM #{enum_value_list(enum)};
    SQL

    if column_name == :type
      execute <<-SQL.squish
        ALTER TABLE #{table_name}
          ALTER COLUMN #{column_name} TYPE #{enum_name}
          USING #{column_name}::#{enum_name}
      SQL

    else
      execute <<-SQL.squish
        ALTER TABLE #{table_name}
          ALTER COLUMN #{column_name} TYPE #{enum_name}
          USING CASE #{column_name}
            #{enum_value_cases(enum_name, enum)}
          END
      SQL
    end

    return unless default

    execute <<-SQL.squish
      ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET DEFAULT '#{default}';
    SQL
  end

  def rollback_enum(table_name, column_name, enum_name, default = nil)
    if default
      execute <<-SQL.squish
        ALTER TABLE #{table_name} ALTER COLUMN #{column_name} DROP DEFAULT;
      SQL
    end

    execute <<-SQL.squish
      ALTER TABLE #{table_name}
        ALTER COLUMN #{column_name} TYPE #{column_name == :type ? 'character varying' : 'integer'}
        USING 0;

      DROP TYPE #{enum_name};
    SQL

    return unless default

    execute <<-SQL.squish
      ALTER TABLE #{table_name} ALTER COLUMN #{column_name} SET DEFAULT #{default};
    SQL
  end

  def enum_value_list(enum)
    "(#{enum.values.map { |val| "'#{val}'" }.join(',')})"
  end

  def enum_value_cases(enum_name, enum)
    enum.values.map.with_index do |value, i|
      "WHEN #{i} THEN '#{value}'::#{enum_name}"
    end.join("\n")
  end
end
