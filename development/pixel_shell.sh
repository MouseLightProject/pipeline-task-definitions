#!/usr/bin/env bash


# Standard arguments passed to all tasks.
pipeline_input_root=${1}
pipeline_output_root=${2}
tile_relative_path=${3}
tile_name=${4}

# User-defined arguments
expected_exit_code=${5}
is_cluster_job=${6}
ilastik_project="${7}/PixelTest.ilp"


# Default location on test machines.  Most configurations should export IL_PREFIX in their launch script that also sets
# machine id, etc.
if [ -z "$IL_PREFIX" ]
then
  if [ "$(uname)" == "Darwin" ]
  then
    IL_PREFIX=/Volumes/Spare/Projects/MouseLight/Classifier/ilastik/ilastik-1.1.8-OSX.app/Contents/ilastik-release
  else
    IL_PREFIX=/groups/mousebrainmicro/mousebrainmicro/cluster/software/ilastik-1.1.9-Linux
  fi
fi

output_format="hdf5"

exit_code=255

# args: channel index, input file base name, output file base name
perform_action () {
    input_file="${2}.${1}.tif"
    output_file="${3}.${1}.h5"

    echo ${input_file}
    echo ${output_file}

    cmd="${IL_PREFIX}/bin/python ${IL_PREFIX}/ilastik-meta/ilastik/ilastik.py --headless --cutout_subregion=\"[(None,None,None,0),(None,None,None,1)]\" --project=\"${ilastik_project}\" --output_filename_format=\"${output_file}\" --output_format=\"${output_format}\" \"$input_file\""
    eval ${cmd}

    # Store before the next calls change the value.
    exit_code=$?

    if [ -e ${output_file} ]
    then
        chmod 775 ${output_file}
    fi
}

export LD_LIBRARY_PATH=""
export PYTHONPATH=""
export QT_PLUGIN_PATH=${IL_PREFIX}/plugins


export LAZYFLOW_THREADS=2
export LAZYFLOW_TOTAL_RAM_MB=600

# Compile derivatives
input_base="${pipeline_input_root}/${tile_relative_path}/${tile_name}-ngc"
output_base="${pipeline_output_root}/${tile_relative_path}/${tile_name}-prob"

echo ${input_base}
echo ${output_base}

for idx in `seq 0 1`
do
    perform_action ${idx} "${input_base}" "${output_base}"

    if [ ${exit_code} -eq ${expected_exit_code} ]
    then
      echo "Completed classifier for channel 0."
    else
      echo "Failed classifier for channel 0."
      exit ${exit_code}
    fi
done

exit ${exit_code}
