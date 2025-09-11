module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  testResultsProcessor: 'jest-junit',
  reporters: [
    'default',
    ['jest-junit', { 
      outputDirectory: 'test-results',
      outputName: 'junit.xml'
    }]
  ],
  testMatch: [
    '**/tests/**/*.test.js',
    '**/__tests__/**/*.js'
  ],
  collectCoverageFrom: [
    'app.js',
    '!**/node_modules/**',
    '!**/coverage/**'
  ]
};
