const core = require('@actions/core');
const { setupCITools } = require('./action');

try {
    core.group('Build CI Tools data', setupCITools);
} catch (error) {
    core.setFailed(error.message);
}