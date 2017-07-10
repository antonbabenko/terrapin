#!/bin/bash

#
# This script runs all templates tests
#

set -e
shopt -s dotglob

# Locate the directory in which this script is located
readonly SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Name of templates directory
readonly TEMPLATES_DIR="templates"

function log {
  local readonly message="$1"
  local readonly script_name="$(basename "$0")"

  >&2 echo -e "[$script_name] $message"
}

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    echo "ERROR: The value for '$arg_name' cannot be empty"
    exit 1
  fi
}

function assert_file_exists {
  local readonly file="$1"

  if [[ ! -f "${file}" ]]; then
    echo "ERROR: The file '$file' is required by this script, but it does not exist."
    exit 1
  fi
}

# Assert that a given binary is installed
function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    echo "ERROR: The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

# Assert that a given pip package is installed
function assert_pip_package_is_installed {
  local readonly name="$1"

  if [[ ! $(pip list --format=columns | grep -F "$name") ]]; then
    echo "ERROR: The pip package '$name' is required by this script but is not installed or in the system's PATH. Run 'pip install $name'."
    exit 1
  fi
}

# Assert that the given directory exists
function assert_dir_exists {
  local readonly dir="$1"

  if [[ ! -d "$dir" ]]; then
    log "ERROR: The directory $dir must exist."
    exit 1
  fi
}

####################################################################
function test_templates {
  local readonly templates_dir="$1"
  local readonly working_dir="$2"

  assert_not_empty "templates_dir" "$templates_dir"
  assert_not_empty "working_dir" "$working_dir"

  cd "$SCRIPT_PATH/.."

  local output_dir="$working_dir/output"

  # Recreate empty working directory
  rm -rf "$working_dir"
  mkdir -p "$working_dir"

  mkdir -p "$output_dir"

  # Render all tpl-files and remove .tpl extension
  local tpl_files=($(find "$templates_dir" -name "*.jinja2" -type f))

  set +e

  for tpl_file in "${tpl_files[@]}"; do
    tpl_filename="$(basename ${tpl_file%.*})"
    out_filename="${tpl_filename}.tf"

    # Cleanup previous results
    rm -rf "$output_dir/*"

    # prepend
    cat <<EOF > "$working_dir/${tpl_filename}.jinja2"
$(cat $SCRIPT_PATH/../templates/macros/macros.jinja2)
$(cat $tpl_file)
EOF

    # log "jinja2 --strict $tpl_file $include_features_file > $output_dir/$output_file"

    jinja2 -e jinja2_terraform.TerraformExtension --strict "$working_dir/${tpl_filename}.jinja2" > "$output_dir/$out_filename"

    terraform_fmt "$output_dir"

    # Coloring sed is taken here - https://stackoverflow.com/questions/8800578/colorize-diff-on-the-command-line#comment48310602_16865578
    diff -Bwu "$templates_dir/$out_filename" "$output_dir/$out_filename" | \
    sed 's/^-/\x1b[31m-/;s/^+/\x1b[32m+/;s/^@/\x1b[34m@/;s/$/\x1b[0m‌​/'
  done

  set -e

}

function terraform_fmt {
  local readonly dir="$1"

  terraform fmt "$SCRIPT_PATH/../$dir"
}

function run_tests {
  assert_is_installed "terraform"
  assert_pip_package_is_installed "jinja2-cli"

  local templates_dir="tests/templates/basic"
  local working_dir="work/$templates_dir"

  # Verify that all required files and directories exist
  assert_dir_exists "$templates_dir"

  log "Testing templates output $templates_dir"
  test_templates "$templates_dir" "$working_dir"

}

run_tests "$@"
