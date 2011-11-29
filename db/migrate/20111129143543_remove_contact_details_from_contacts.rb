class RemoveContactDetailsFromContacts < ActiveRecord::Migration
  def change
    change_table :contacts do |t|
      t.remove :postal_address, :email_address, :website_url, :opening_hours, :phone_numbers
    end
  end
end
