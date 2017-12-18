class CreateUnsentMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :unsent_messages do |t|
      t.string :phone_number
      t.integer :entry_id
      t.text :entry_body

      t.timestamps
    end
  end
end
