require 'open-uri'

class Contact < ActiveRecord::Base
  serialize :phone_numbers
  composed_of :contactotron_uri,
    :class_name   => 'URI',
    :mapping      => %w(contactotron_uri to_s),
    :constructor  => :parse,
    :converter    => :parse

  validates :name, :presence => true

  scope :in_alphabetical_order, order(arel_table[:name].asc)

  def update_from_contactotron
    update_attributes! data_from_contactotron.slice(:name, :postal_address, :phone_numbers, :email_address, :website_url, :opening_hours)
  end

  private
    def json_from_contactotron
      contactotron_uri.read 'Accept' => Mime::JSON.to_s
    end

    def data_from_contactotron
      ActiveSupport::JSON.decode(json_from_contactotron).with_indifferent_access
    end
end
