# db/migrate/[timestamp]_create_students.rb
class CreateStudents < ActiveRecord::Migration[6.1]
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.integer :invoice_amount
      t.string :email
      t.string :phone
      t.references :parent, foreign_key: true

      t.timestamps
    end
  end
end

