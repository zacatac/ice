class AddBirthToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :birth, :date
  end
end
