#!/bin/bash
set -eou pipefail

## This file take input YAML file with multiple k8s custom resources and splits
## each resource into its own JSON file.
## The goal is to avoid additional tools and languages. There could be better ways to do it, like:
## https://stackoverflow.com/questions/59404550/how-to-split-a-yaml-into-multiple-files-with-a-proper-name
##
## LIMITATIONS
## Assumes no "---" on first line
## Not directory safe and minimal validation

file=$1
dir=$2
copy_file=copy-$file
tmp_file=tmp-dc7b0f56.yaml

trap "rm -f $copy_file $tmp_file" EXIT

if [ $# -eq 0 ]; then
  echo "Please provide input file and destination directory" && exit 1
fi

cp $file $copy_file
echo "---" >> $copy_file # avoids special case for last block

# line_nums is array of line numbers where --- is found and 0 as a first element
line_nums=(0 $(grep -n "\-\-\-" $copy_file | cut -d:  -f 1 - | tr -s '\n' ' '))

for (( i=0; i < $(( ${#line_nums[@]} - 1)); i++ )); do
  sed -n "$((${line_nums[$i]}+1)),$((${line_nums[((i+1))]}-1))p" $copy_file > $tmp_file
  kind=$(yq e .kind $tmp_file | tr '[:upper:]' '[:lower:]')
  name=$(yq e .metadata.name $tmp_file)
  echo writing file $kind-$name
  # if/else - leave as yaml or convert
  # mv tmp.yaml ${dir}/${kind}-${name}.yaml
  yq e . -j -P $tmp_file > ${dir}/${kind}-${name}.json
done
