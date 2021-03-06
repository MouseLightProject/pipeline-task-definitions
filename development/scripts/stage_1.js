const path = require("path");
const fs = require("fs");

function readArg(index) {
    return process.argv.length > index ? process.argv[index] : null;
}

let index = 2;

const pipeline_input_root = readArg(index++);
const pipeline_output_root = readArg(index++);
const tile_relative_path = readArg(index++);
const tile_name = readArg(index++);
const project_name = readArg(index++);
const project_root = readArg(index++);
const log_root_path = readArg(index++);
const expected_exit_code = readArg(index++);
const task_id = readArg(index++);
const is_cluster_job = readArg(index++);
const x = readArg(index++);
const y = readArg(index++);
const z = readArg(index++);
const step_x = readArg(index++);
const step_y = readArg(index++);
const step_z = readArg(index++);

fs.writeFileSync(path.join(pipeline_output_root, tile_relative_path, `${tile_name}.json`), JSON.stringify({
    pipeline_input_root,
    pipeline_output_root,
    tile_relative_path,
    tile_name,
    project_name,
    project_root,
    log_root_path,
    expected_exit_code,
    task_id,
    is_cluster_job,
    x,
    y,
    z,
    step_x,
    step_y,
    step_z
}, null, 4));
