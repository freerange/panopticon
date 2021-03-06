require_relative '../../test_helper'

class TagsHelperTest < ActiveSupport::TestCase
  include TagsHelper

  context "grouped_options_for_tags_of_type" do
    setup do
      create(:live_tag, tag_type: "section", tag_id: "tax", title: "Tax")
      create(:live_tag, tag_type: "section", tag_id: "driving", title: "Driving")
      create(:live_tag, tag_type: "section", tag_id: "driving/car-tax", title: "Car tax", parent_id: "driving")
      create(:live_tag, tag_type: "section", tag_id: "driving/mot", title: "MOT", parent_id: "driving")

      create(:live_tag, tag_type: "legacy_source", tag_id: "directgov", title: "Directgov")
    end

    should "return a hierarchy of parent tags and their children" do
      expected = [
        [ "Driving", [ ["Driving", "driving"], ["Driving: Car tax", "driving/car-tax"], ["Driving: MOT", "driving/mot"] ]],
        [ "Tax", [["Tax", "tax"]] ]
      ]

      assert_equal expected, grouped_options_for_tags_of_type("section")
    end
  end

end
