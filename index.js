const core = require('@actions/core');
// const github = require('@actions/github');
const path = require('path')

try {
    core.debug(`CI tools actioins`);
    script_path = path.join(__dirname, 'scripts')
    core.setOutput("scripts", script_path);
    console.log(script_path)
} catch (error) {
    core.setFailed(error.message);
}