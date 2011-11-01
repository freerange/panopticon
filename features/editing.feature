Feature: Editing artefacts
  In order to maintain GovUK metadata
  I want to edit artefacts

  Scenario: Assign a related item
    Given an artefact exists with a name of "Probation"
      And an artefact exists with a name of "Leaving prison"

    Then the API should say that "Leaving prison" is not related to "Probation"

    When I am editing "Probation"
      And I add "Leaving prison" as a related item
      And I save my changes

    Then I should be redirected to "Probation" on Publisher
      And the rest of the system should be notified that "Probation" has been updated
      And the API should say that "Leaving prison" is related to "Probation"

  Scenario: Unassign a related item
    Given an artefact exists with a name of "Probation"
      And an artefact exists with a name of "Leaving prison"
      And "Leaving prison" is related to "Probation"

    Then the API should say that "Leaving prison" is related to "Probation"

    When I am editing "Probation"
      And I remove "Leaving prison" as a related item
      And I save my changes

    Then I should be redirected to "Probation" on Publisher
      And the rest of the system should be notified that "Probation" has been updated
      And the API should say that "Leaving prison" is not related to "Probation"

  Scenario: Assign additional related items
    Given the following artefacts exist:
      | name                                        |
      | Driving disqualifications                   |
      | Book the practical driving test             |
      | Driving before your licence is returned     |
      | National Driver Offender Retraining Scheme  |
      | Apply for a new driving licence             |
      | Get a divorce                               |

      And "Book the practical driving test" is related to "Driving disqualifications"
      And "Driving before your licence is returned" is related to "Driving disqualifications"

    Then the API should say that "Book the practical driving test" is related to "Driving disqualifications"
      And the API should say that "Driving before your licence is returned" is related to "Driving disqualifications"
      And the API should say that "National Driver Offender Retraining Scheme" is not related to "Driving disqualifications"
      And the API should say that "Apply for a new driving licence" is not related to "Driving disqualifications"
      And the API should say that "Get a divorce" is not related to "Driving disqualifications"

    When I am editing "Driving disqualifications"
      And I add "National Driver Offender Retraining Scheme" as a related item
      And I add "Apply for a new driving licence" as a related item
      And I save my changes

    Then I should be redirected to "Driving disqualifications" on Publisher
      And the rest of the system should be notified that "Driving disqualifications" has been updated
      And the API should say that "Book the practical driving test" is related to "Driving disqualifications"
      And the API should say that "Driving before your licence is returned" is related to "Driving disqualifications"
      And the API should say that "National Driver Offender Retraining Scheme" is related to "Driving disqualifications"
      And the API should say that "Apply for a new driving licence" is related to "Driving disqualifications"
      And the API should say that "Get a divorce" is not related to "Driving disqualifications"
