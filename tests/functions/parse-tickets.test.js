const { parseTickets } = require('../../functions/parse-tickets')
const fs = require('fs')
const yml = require('js-yaml')
const Ajv = require('ajv')

describe('index.js Happy Paths', () => {
  const testDataContent = fs.readFileSync('./tests/functions/parse-tickets.test.data.json')
  const testData = JSON.parse(testDataContent)
  const ajv = new Ajv({ useDefaults: true }) // add default values to the config properties
  const schemaPath = 'config.schema.yml'
  const schemaContent = fs.readFileSync(schemaPath)
  const schema = yml.load(schemaContent)
  const validate = ajv.compile(schema)

  testData
    .filter(x => x.enabled)
    .forEach(data => {
      it(data.scenario, () => {
        // arrange
        const configContent = fs.readFileSync(data.configuration)
        const config = yml.load(configContent)

        const valid = validate(config) // add the default values to the config
        if (!valid) {
          const errorsJson = JSON.stringify(validate.errors, null, 2)
          throw new Error(`Invalid configuration:\n${errorsJson}`)
        }

        // act
        const result = parseTickets(config.tickets, data.commitMsg)

        // assert
        expect(result).toEqual(data.result)
      })
    })

  afterEach(() => {
    jest.clearAllMocks()
  })
})
