class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :document_id
      t.string :user_id
      t.string :document_path
      t.boolean :p_update
      t.boolean :p_delete
      t.boolean :p_move
      t.boolean :p_share
      t.boolean :p_view
      t.boolean :p_upload
      t.boolean :p_create_folder

      t.timestamps
    end
  end
end
