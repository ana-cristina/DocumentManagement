class CreateGithubUsers < ActiveRecord::Migration
  def change
    create_table :github_users do |t|
      t.string :username
      t.string :token
      t.string :user_id
      t.string :git_id

      t.timestamps
    end
  end
end
