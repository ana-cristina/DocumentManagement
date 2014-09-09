class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :document_id
      t.string :document_path
      t.boolean :folder_or_file
      t.string :document_name
      t.string :document_uploader
      t.integer :parent_dir

      t.timestamps
    end
  end
end
