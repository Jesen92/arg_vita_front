class CreateContactForms < ActiveRecord::Migration
  def change
    create_table :contact_forms do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message

      t.timestamps null: false
    end
  end
end
