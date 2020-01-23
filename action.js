const core = require('@actions/core');
// const github = require('@actions/github');
const path = require('path')
const tc = require('@actions/tool-cache');

function setupCITools() {
    const variableInput = core.getInput('variables', { required: false });
    exportInputVariable(variableInput);
    const oc_client = (core.getInput('oc_client') || 'true').toUpperCase() === 'TRUE';

    if(oc_client) {
        const oc_client_url = core.getInput('oc_client_url', { required: true });
        const ocClientPath = await tc.downloadTool(oc_client_url);
        const ocCLientExtractedFolder = await tc.extractTar(ocClientPath, process.env.RUNNER_TEMP);
        ocBinary = path.join(ocCLientExtractedFolder, 'oc');
        console.log("ocBinary="+ocBinary);
        const cachedPath = await tc.cacheDir(ocBinary, 'oc', '1');
        core.addPath(cachedPath);
        core.setOutput("oc", cachedPath);
        console.log("Output variable: oc="+cachedPath);
    }

    script_path = path.join(__dirname, 'scripts')
    core.setOutput("scripts", script_path);
    console.log("Output variable: scripts="+script_path)
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
        let outputName = null;

        const pathParts = path
            .split(/\|+/)
            .map(part => part.trim())
            .filter(part => part.length !== 0);

        if (pathParts.length !== 2) {
            throw Error(`You must provide a valid variable and variable value. Input: "${variableInput}"`)
        }

        const [varName, varValue] = pathParts;
        console.log("  - "+varName+"="+varValue);
        core.exportVariable(varName, varValue);
    }
}

module.exports = {
    setupCITools,
    exportInputVariable
};