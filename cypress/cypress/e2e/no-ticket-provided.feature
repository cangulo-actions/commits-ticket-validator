Feature: NO ticket provided and validate based on configuration

  Background: The gh action runs with config
    Given I create a repository named "ctv-PR-{PR_NUMBER}-{TEST_KEY}"
    And I push the file "tickets-config-test.yml" to the branch "main" with the content:
      """
      tickets:
        - name: GH Issues
          pattern: '#(\d+)'
          url: https://github.com/cangulo-actions/commits-ticket-validator/issues/$TICKET
        - name: payments projects
          pattern: 'PAY-\d+'
          url: https://cangulo.atlassian.net/browse/$TICKET
        - name: cangulo blog
          pattern: '[A-Z]{4}-\d+'
          url: https://cangulo.atlassian.net/browse/$TICKET
      """
    And I push the file ".github/workflows/ctv-test.yml" to the branch "main" with the content:
      """
      name: cangulo-actions/commits-ticket-validator test
      on:
        pull_request: 
          branches:
            - main
      
      jobs:
        validate-commits:
          name: Validate Commits
          runs-on: ubuntu-latest
          permissions:
            contents: read
            pull-requests: read
          steps:
            - name: Checkout
              uses: actions/checkout@v4
      
            - name: Validate Tickets
              uses: cangulo-actions/commits-ticket-validator@<TARGET_BRANCH>
              with:
                configuration: tickets-config-test.yml
      """

  Scenario: Commits with valid scopes
    Given I create a branch named "valid-commits-scopes"
    And I push the next commits modifying the files:
      | <commig message>                          | <file>       |
      | fix: solved error in the reporting system | src/index.ts |
    When I create a PR with title "valid-commits: modifications match configuration"
    Then the workflow "cangulo-actions/commits-ticket-validator test" must conclude in "failure"
