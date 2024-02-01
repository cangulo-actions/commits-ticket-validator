Feature: Print tickets summary

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
                print-summary: true
      """

  Scenario: Commits with valid scopes
    Given I create a branch named "valid-commits-scopes"
    And I push the next commits modifying the files:
      | <commig message>                                                      | <file>               |
      | fix: #123 solved error related to GH issue 123 and also finished #332 | src/index.ts         |
      | fix: PAY-234 fixed error in payment service                           | src/payment-index.ts |
      | BLOG-3452 commit adding info to the blog                              | src/blog-index.ts    |
    When I create a PR with title "valid-commits: modifications match configuration"
    Then the workflow "cangulo-actions/commits-ticket-validator test" must conclude in "success"
    # ⚠️🤷 THERE IS NO WAY TO CHECK THE SUMMARY IS LISTED USING THE GH API
