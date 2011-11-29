require 'test_helper'

class ArtefactTest < ActiveSupport::TestCase
  test "it allows nice clean slugs" do
    a = Artefact.new(:slug => "its-a-nice-day")
    a.valid?
    assert a.errors[:slug].empty?
  end
  
  test "it doesn't allow apostrophes in slugs" do
    a = Artefact.new(:slug => "it's-a-nice-day")
    assert ! a.valid?
    assert a.errors[:slug].any?
  end
  
  test "it doesn't allow spaces in slugs" do
    a = Artefact.new(:slug => "it is-a-nice-day")
    assert ! a.valid?
    assert a.errors[:slug].any?
  end

  test '#contact_uri should return the contact\'s URI' do
    contact = Factory.build :contact, :contactotron_uri => 'http://contactotron.example/contacts/42'
    artefact = Factory.build :artefact, :contact => contact
    assert_equal 'http://contactotron.example/contacts/42', artefact.contact_uri
  end
end
