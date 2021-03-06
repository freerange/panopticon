require_relative '../../test_helper'

class SpecialistSectorTagFormTest < ActiveSupport::TestCase
  context '#valid?' do
    subject do
      SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
    end

    context 'with an unused slug' do
      should 'be true' do
        assert subject.valid?
      end
    end

    context 'with an already taken slug' do
      setup do
        FactoryGirl.create(:artefact, slug: 'oil-and-gas')
      end

      should 'be false' do
        refute subject.valid?
      end

      should 'include a validation error for tag_id' do
        subject.valid?
        assert subject.errors[:tag_id].include?('is already taken')
      end
    end
  end

  context '#save' do
    setup do
      stub_all_router_api_requests
      stub_all_rummager_requests
    end

    should 'create a live artefact for a live tag' do
      subject = SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
      subject.state = 'live'

      assert_difference 'Artefact.count', 1 do
        subject.save
      end

      artefact = Artefact.last

      assert_equal 'specialist_sector', artefact.kind
      assert_equal 'panopticon', artefact.owning_app
      assert_equal 'collections', artefact.rendering_app
      assert_equal 'Oil and gas', artefact.name
      assert_equal 'oil-and-gas', artefact.slug
      assert_equal 'live', artefact.state
    end

    should 'set paths for a parent tag' do
      subject = SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
      subject.state = 'live'

      assert_difference 'Artefact.count', 1 do
        subject.save
      end

      artefact = Artefact.last
      assert_equal ['/oil-and-gas'], artefact.paths
      assert_equal [], artefact.prefixes
    end

    should 'set prefixes for a child tag' do
      parent_tag = FactoryGirl.create(:tag, tag_type: 'specialist_sector', tag_id: 'oil-and-gas')

      subject = SpecialistSectorTagForm.new(
        title: 'Licensing',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas/licensing',
        parent_id: parent_tag.tag_id
      )
      subject.state = 'live'

      assert_difference 'Artefact.count', 1 do
        subject.save
      end

      artefact = Artefact.last
      assert_equal [], artefact.paths
      assert_equal ['/oil-and-gas/licensing'], artefact.prefixes
    end

    should 'create a draft artefact for a draft tag' do
      subject = SpecialistSectorTagForm.new(
        title: 'Oil and gas',
        tag_type: 'specialist_sector',
        tag_id: 'oil-and-gas',
      )
      subject.state = 'draft'

      assert_difference 'Artefact.count', 1 do
        subject.save
      end

      artefact = Artefact.last

      assert_equal 'draft', artefact.state
    end
  end
end
