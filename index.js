const core = require('@actions/core');
const github = require('@actions/github');

try {
    core.debug(`CI tools actioins`);
    console.log(__dirname)
} catch (error) {
    core.setFailed(error.message);
}