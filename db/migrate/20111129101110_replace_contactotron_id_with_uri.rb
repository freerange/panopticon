class ReplaceContactotronIdWithUri < ActiveRecord::Migration
  def up
    change_table :contacts do |t|
      t.string :contactotron_uri, :null => false, :after => :contactotron_id
    end

    Contact.reset_column_information
    Contact.all.each do |contact|
      contact.update_attributes! :contactotron_uri => Contact.contactotron_uri_from_id(contact.contactotron_id)
    end

    change_table :contacts do |t|
      t.remove :contactotron_id
    end
  end

  def down
    change_table :contacts do |t|
      t.integer :contactotron_id, :null => false, :after => :contactotron_uri
    end

    Contact.reset_column_information
    Contact.all.each do |contact|
      contact.update_attributes! :contactotron_id => Contact.contactotron_id_from_uri(contact.contactotron_uri)
    end

    change_table :contacts do |t|
      t.remove :contactotron_uri
    end
  end
end

class Contact < ActiveRecord::Base
  # before
  def self.contactotron_uri_from_id(contactotron_id)
    URI.parse(Plek.current.find('contactotron')).tap do |uri|
      uri.path = "/contacts/#{contactotron_id}"
    end
  end

  # after
  composed_of :contactotron_uri,
    :class_name   => 'URI',
    :mapping      => %w(contactotron_uri to_s),
    :constructor  => :parse,
    :converter    => :parse

  def self.contactotron_id_from_uri(contactotron_uri)
    contactotron_uri.path.match(/\d+$/)[0].to_i
  end
end
