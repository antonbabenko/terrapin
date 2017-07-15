#!/bin/bash

#
# This script generates code for Terraform module from templates directory with user-defined variables
#

set -e
shopt -s dotglob

# Locate the directory in which this script is located
readonly SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Name of output destination directory
readonly OUTPUT_DIR="output"

# Name of working directory
readonly WORKING_DIR="work"

# Name of templates directory
readonly TEMPLATES_DIR="templates"

# Name of file with meta settings for the module
readonly META_FILE="meta.yml"

# String marker used to split single template into pieces
readonly STRING_MARKER=$(date | md5)

function print_usage {
  echo
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "This script validates, combines and generate module code."
  echo
  echo "Required Arguments:"
  echo
  echo -e "  --module\t\tThe name of terraform module to work with (can be used multiple times)"
  echo -e "  --validate\tValidate templates"
  echo -e "  --generate-all\tGenerate all templates"
  echo
  echo "Optional Arguments:"
  echo
  echo -e "  --help\t\tShow this help text and exit."
  echo
  echo "Example:"
  echo
  echo "  $0 --module aws_bastion_s3_keys --validate"
  echo "  $0 --module aws_bastion_s3_keys --generate-all"
}

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

# Replace a line of text in a file. Only works for single-line replacements.
function replace_text_in_file {
  local readonly original_text_regex="$1"
  local readonly replacement_text="$2"
  local readonly file="$3"

  sed -i "s|$original_text_regex|$replacement_text|" "$file"
}

####################################################################
function prepare_module_working_dir {
  local readonly working_dir="$1"
  local readonly module_dir="$2"

  assert_not_empty "working_dir" "$working_dir"
  assert_not_empty "module_dir" "$module_dir"

  cd "$SCRIPT_PATH/.."

  # Recreate empty working directory
  rm -rf "$working_dir"
  mkdir -p "$working_dir"

  # Copy entire module there
  cp -Rf "$module_dir"/* "$working_dir"

  # Copy entire tests there
  cp -Rf "$SCRIPT_PATH"/../templates/tests "$working_dir"

  # Copy entire examples there
  cp -Rf "$SCRIPT_PATH"/../templates/examples "$working_dir"

  # Copy entire docs there
  cp -Rf "$SCRIPT_PATH"/../templates/docs "$working_dir"
}

function compose_module_templates {
  local readonly working_dir="$1"
  local readonly templates_dir="$TEMPLATES_DIR"

#  cd "$SCRIPT_PATH/.."

  # read meta.yml file and decide what templates to copy to working directory
#  local templates_to_use=$(cat "$working_dir/$META_FILE" | shyaml get-value template)

  # 1. copy required templates here
#  cp -f templates/"$templates_to_use"/* "$working_dir/$templates_dir"

  # 2. copy static resources (models and documentation)
#  cp -Rf resources/model/providers_out "$working_dir/$templates_dir/model"
#  cp -Rf resources/doc/providers_out "$working_dir/$templates_dir/doc"

  # 3. append and prepend include statements to main.tf.tpl OR use jinja2 include/import in main.tf.tpl
  cd "$working_dir/$templates_dir"
  echo -e "$(cat $SCRIPT_PATH/../templates/macros/macros.jinja2)
$(cat main.tf.tpl)
###${STRING_MARKER}_1###
{{ variables() }}
###${STRING_MARKER}_2###
{{ outputs() }}" > main.tf.tpl

}

function generate_templates {
  local readonly working_dir="$1"
  local readonly output_dir="$2"
  local readonly templates_dir="$working_dir/$TEMPLATES_DIR"
  local readonly features_file="$templates_dir/features.yml"
  local include_features_file=""

  assert_not_empty "working_dir" "$working_dir"
  assert_not_empty "output_dir" "$output_dir"

  cd "$SCRIPT_PATH/.."

  # Recreate empty working directory
  rm -rf "$output_dir"
  mkdir -p "$output_dir"

  # use features, if features.yml exists
  if [[ -f "${features_file}" ]]; then
    local include_features_file="$features_file"
  fi

  # Render all tpl-files and remove .tpl extension
  local tpl_files=($(find "$templates_dir" -name "*.tpl" -type f))

  for tpl_file in "${tpl_files[@]}"; do
    output_file="$(dirname ${tpl_file})/$(basename ${tpl_file%.*})"

    log "jinja2 --strict $tpl_file $include_features_file > $output_file"

    jinja2 -e jinja2_terraform.TerraformExtension --strict "$tpl_file" $include_features_file > "$output_file"

    # Move variables and outputs to separate tf files
    pos1=$(sed -n "/###${STRING_MARKER}_1###/=" "$output_file")
    pos2=$(sed -n "/###${STRING_MARKER}_2###/=" "$output_file")

    if [[ -n "$pos1" && -n "$pos2" ]]; then
      sed -n "$((${pos1}+1)),$((${pos2}-2))p" "$output_file" > "$output_dir/variables.tf"
      sed -n "$((${pos2}+2)),\$p" "$output_file" > "$output_dir/outputs.tf"

      # Delete them from main template
      sed -i "${pos1},\$ d" "$output_file"
    fi

    rm "$tpl_file"
  done

  # Copy all files to output
  cp -Rf "$templates_dir"/* "$output_dir"
}

function render_templates {
  local readonly working_dir="$1"
  local readonly output_dir="$2"
#  local readonly templates_dir="$working_dir/tests"

  assert_not_empty "working_dir" "$working_dir"
  assert_not_empty "output_dir" "$output_dir"

  cd "$SCRIPT_PATH/.."

  mkdir -p "$output_dir"

  # Render all tpl-files and remove .tpl extension
  local tpl_files=($(find "$working_dir" -name "*.tpl" -type f))

  for tpl_file in "${tpl_files[@]}"; do
    output_file="$(dirname ${tpl_file})/$(basename ${tpl_file%.*})"

    log "jinja2 --strict $tpl_file > $output_file"

    jinja2 -e jinja2_terraform.TerraformExtension --strict "$tpl_file" > "$output_file"

    rm "$tpl_file"
  done

  # Copy all tests files to output
  cp -Rf "$working_dir"/* "$output_dir"
}

function terraform_fmt {
  local readonly dir="$1"

  cd "$SCRIPT_PATH/../$dir"

  terraform fmt
}

function create_archive {
  local readonly dir="$1"
  local readonly archive="$2"

  cd "$SCRIPT_PATH/../$dir"

  zip -FS -r -9 "$SCRIPT_PATH/../work/${archive}" *
}

function generate_module {
  local module=""
  local do_validate=false
  local do_generate=false

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
    --module)
      module="$2"
      shift
      ;;
    --validate)
      do_validate=true
      ;;
    --generate)
      do_generate=true
      ;;
    --help)
      print_usage
      exit
      ;;
    *)
      echo "ERROR: Unrecognized argument: $key"
      print_usage
      exit 1
      ;;
    esac

    shift
  done

  assert_is_installed "jq"
  assert_is_installed "pip"
  assert_is_installed "zip"
  assert_is_installed "terraform"
  assert_pip_package_is_installed "jinja2-cli"

  assert_not_empty "module" "$module"

  # Generate templates
  local module_dir="modules/$module"
  local module_templates_dir="$module_dir/$TEMPLATES_DIR"
  local module_meta_file="$module_dir/$META_FILE"

  local module_output_dir="$OUTPUT_DIR/$module_dir"
  local module_src_output_dir="$module_output_dir/src"
  local module_tests_output_dir="$module_output_dir/tests"
  local module_examples_output_dir="$module_output_dir/examples"

  local module_working_dir="$WORKING_DIR"
#  local module_templates_working_dir="$module_working_dir/templates"
  local module_tests_working_dir="$module_working_dir/tests"
  local module_examples_working_dir="$module_working_dir/examples"
  local module_docs_working_dir="$module_working_dir/docs"

  # Verify that all required files and directories exist
  assert_dir_exists "$module_dir"
  assert_dir_exists "$module_templates_dir"
  assert_file_exists "$module_meta_file"

  log "Preparing module working directory $module_working_dir"
  prepare_module_working_dir "$module_working_dir" "$module_dir"

  log "Composing module templates"
  compose_module_templates "$module_working_dir"

  log "Render templates to $module_src_output_dir"
  generate_templates "$module_working_dir" "$module_src_output_dir"

  log "Running terraform fmt"
  terraform_fmt "$module_src_output_dir"

  log "Render tests to $module_tests_output_dir"
  render_templates "$module_tests_working_dir" "$module_tests_output_dir"

  log "Render examples to $module_examples_output_dir"
  render_templates "$module_examples_working_dir" "$module_examples_output_dir"

  log "Render docs to $module_output_dir"
  render_templates "$module_docs_working_dir" "$module_output_dir"

  log "Generation complete!!!!"

  log "Creating archive ./work/${module}.zip"
  create_archive "$module_output_dir" "${module}.zip"

#  log "Uploading archive to dev s3 bucket (environment)"
}

generate_module "$@"
