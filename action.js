const core = require('@actions/core');
// const github = require('@actions/github');
const path = require('path')

function setupCITools() {
    const variableInput = core.getInput('variables', { required: false });
    exportInputVariable(variableInput);

    core.debug(`CI tools actioins`);
    script_path = path.join(__dirname, 'scripts')
    core.setOutput("scripts", script_path);
    console.log(script_path)
}

function exportInputVariable(variableInput) {
    const vars = variableInput
        .split(';')
        .filter(key => !!key)
        .map(key => key.trim())
        .filter(key => key.length !== 0);

    /** @type {{ secretPath: string; outputName: string; dataKey: string; }[]} */
    const output = [];
    for (const varToExport of vars) {
        let path = varToExport;
        let outputName = null;

        const pathParts = path
            .split(/\s+/)
            .map(part => part.trim())
            .filter(part => part.length !== 0);

        if (pathParts.length !== 2) {
            throw Error(`You must provide a valid variable and variable value. Input: "${secret}"`)
        }

        const [varName, varValue] = pathParts;
        core.exportVariable(varName, varValue)
    }
}

module.exports = {
    setupCITools,
    exportInputVariable
};