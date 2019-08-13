'use strict';

const express = require('express');
const datadog = require('connect-datadog');
const StatsD = require('node-dogstatsd').StatsD;
const tracer = require('dd-trace');
const Sentry = require('@sentry/node');

// Datadog setup
const datadog_options = {
  'response_code': true,
  'tags': ['app:example_app']
};
const dogstatsd = new StatsD();

const datadog_middleware = datadog(datadog_options);

tracer.init();

// Sentry setup
Sentry.init({ dsn: 'https://afe25fdb04b94c7b92becd58c879b107@sentry.io/1529629' });

// Constants
const PORT = 3000;
const HOST = '0.0.0.0';

// Setup routes
const app = express();
app.get('/', (req, res) => {
  res.send('Hello, World!\n');
});

app.get('/one', (req, res) => {
  dogstatsd.increment('page.views.one');
  res.send('one');
});

app.get('/two', (req, res) => {
  dogstatsd.increment('page.views.two');
  res.send('two');
});

app.get('/slow', (req, res) => {
  dogstatsd.increment('page.views.slow');

  setTimeout(() => {
    res.send('slow')
  }, 2000);
});

app.get('/error', function mainHandler(req, res) {
  throw new Error('My first error to test Sentry error reporting (and datadog integration)');
});

app.get('/error2', function mainHandler(req, res) {
  throw new Error('A different error');
});

// Install Middleware
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.errorHandler());
app.use(datadog_middleware);

// Run the App
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);