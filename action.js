const core = require('@actions/core');
// const github = require('@actions/github');
const path = require('path')
const tc = require('@actions/tool-cache');
const fs = require('fs');

async function setupCITools() {
    const variableInput = core.getInput('variables', { required: false });
    exportInputVariable(variableInput);
    const oc_client = (core.getInput('oc_client') || 'true').toUpperCase() === 'TRUE';

    if (oc_client) {
        const oc_client_url = core.getInput('oc_client_url', { required: true });
        const ocClientPath = await tc.downloadTool(oc_client_url);
        const ocCLientExtractedFolder = await tc.extractTar(ocClientPath, process.env.RUNNER_TEMP);
        ocBinary = path.join(ocCLientExtractedFolder, 'oc');
        fs.chmodSync(ocBinary, '0755');
        console.log("Set output variable: oc=" + ocBinary);
        core.setOutput("oc", ocBinary);
        console.log("Export variable: OC_BIN=" + ocBinary);
        core.exportVariable('OC_BIN', ocBinary)
    }

    script_path = path.join(__dirname, 'scripts')
    console.log("Set output variable: scripts=" + script_path)
    core.setOutput("scripts", script_path);
    console.log("Export variable: CI_TOOLS_DIR=" + script_path);
    core.exportVariable('CI_TOOLS_DIR', script_path)
}

function exportInputVariable(variableInput) {
    const vars = variableInput
        .split(';')
        .filter(key => !!key)
        .map(key => key.trim())
        .filter(key => key.length !== 0);

    console.log("Exported variables:")
    const output = [];
    for (const varToExport of vars) {
        let path = varToExport;

        const pathParts = path.split(/\|+/)
            .map(part => part.trim())
            .filter(part => part.length !== 0);

        if (pathParts.length !== 2) {
            throw Error(`You must provide a valid variable and variable value. Input: "${variableInput}"`)
        }

        var [varName, varValue] = pathParts;
        varValue = varValue.replace(/"/g, '');
        console.log("  - " + varName + "=" + varValue);
        core.exportVariable(varName, varValue);
    }
}

module.exports = {
    setupCITools,
    exportInputVariable
};