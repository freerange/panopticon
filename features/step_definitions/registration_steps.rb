Given /^I have stubbed search and router$/ do
  stub_search
  stub_router
end

When /^I put a new smart answer's details into panopticon$/ do
  prepare_registration_environment

  # TODO: Make this work via API Adapters
  # interface = GdsApi::CoreApi.new('test', "http://example.com")
  # interface.register(resource_details)

  put "/artefacts/#{example_smart_answer['slug']}.json", artefact: example_smart_answer
end

When /^I put updated smart answer details into panopticon$/ do
  prepare_registration_environment
  setup_existing_artefact

  artefact_basics = example_smart_answer
  artefact_basics['name'] = 'Something simpler'
  put "/artefacts/#{artefact_basics['slug']}.json", 
    artefact: artefact_basics
end

When /^I put a draft smart answer's details into panopticon$/ do
  prepare_registration_environment
  
  details = example_smart_answer
  details['live'] = false

  put "/artefacts/#{example_smart_answer['slug']}.json", artefact: details
end

When /^I put a new item into panopticon whose slug is already taken$/ do
  prepare_registration_environment
  setup_existing_artefact
  artefact_basics = example_smart_answer
  artefact_basics['name'] = 'Something simpler'
  artefact_basics['owning_app'] = 'planner'
  put "/artefacts/#{artefact_basics['slug']}.json", 
    artefact: artefact_basics
end

Then /^a new artefact should be created$/ do
  assert_equal 201, last_response.status, "Expected 201, got #{last_response.status}"
end

Then /^the relevant artefact should be updated$/ do
  # Check status code of response
  assert_equal 200, last_response.status, "Expected 200, got #{last_response.status}"
end

Then /^I should receive an HTTP (\d+) response$/ do |code|
  assert_equal code.to_i, last_response.status, "Expected #{code}, got #{last_response.status}"
end

Then /^the API should reflect the change$/ do
  check_artefact_has_name_in_api @artefact, 'Something simpler'
end

Then /^the relevant artefact should not be updated$/ do
  assert 'Something simpler' != artefact_data_from_api(@artefact)[:name]
end

Then /^rummager should be notified$/ do
  # We allow one request to search. FakeWeb will decrement
  # the allowed number of requests each time one is made
  assert_equal 1, @fake_search.first.options[:times] - @fake_search.first.times
end

Then /^the router should be notified$/ do
  # We allow one request to the router. FakeWeb will decrement
  # the allowed number of requests each time one is made
  assert_equal 1, @fake_router.first.options[:times] - @fake_router.first.times
end

Then /^rummager should not be notified$/ do
  assert_equal @fake_search.first.options[:times], @fake_search.first.times
end

Then /^the router should not be notified$/ do
  assert_equal @fake_router.first.options[:times], @fake_router.first.times
end