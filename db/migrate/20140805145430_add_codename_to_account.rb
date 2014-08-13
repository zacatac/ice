class AddCodenameToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :codename, :string, :limit => 20
  end
end
