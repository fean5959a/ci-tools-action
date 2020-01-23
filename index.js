const core = require('@actions/core');
const github = require('@actions/github');

try {
 core.debug(`CI tools actioins`);
} catch (error) {
  core.setFailed(error.message);
}