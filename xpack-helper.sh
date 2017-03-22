#!/bin/bash

# -----------------------------------------------------------------------------
# Bash helper script used to experiment with the xpm and xpack commands.
# Must be included with `source xpack-helper.sh`
# -----------------------------------------------------------------------------

# Get the full absolute path of the current script.
script_absolute_path=$0
if [[ "${script_absolute_path}" != /* ]]
then
  # Make relative path absolute.
  script_absolute_path=$(pwd)/$0
fi
# echo $script_absolute_path

if [ -f "package.json" ]
then
  export xpack_root_path="$(pwd)"
else
  echo "Not an xPack folder."
  exit 1
fi

xmake_path="${script_absolute_path}"

xmake_target_name=$(uname | tr '[:upper:]' '[:lower:]')
xmake_toolchain_name="gcc"

tab=$'\t'

# -----------------------------------------------------------------------------
# Common functions

# -----------------------------------------------------------------------------

do_xpm_help() {
  echo "Usage: xpm <command> <options>"
  echo "xpm install "
}

do_xpm() {
  if [ $# -lt 1 ]
  then
    do_xpm_help
    exit 1
  fi

  echo "TODO: implement xpm install"
  exit 1
}

# -----------------------------------------------------------------------------

do_xmake_help() {
  echo "Usage: xmake <command> <options>"
  echo "xmake tests "
  echo "xmake test <name> "
}


do_xmake_tests() {

  while [ $# -gt 0 ]
  do
    case "$1" in
      --toolchain)
        shift
        xmake_toolchain_name="$1"
        shift
        ;;

      --target)
        shift
        xmake_target_name="$1"
        shift
        ;;

      *)
        echo "Unsupported \"$1\", abort."
        exit 1
        ;;
    esac
  done

  # echo do_xmake_tests $@
  for f in $(find tests -name 'test.json' -print)
  do
    test_folder_path=$(dirname ${f})
    test_name=$(basename ${test_folder_path})
    cd "${xpack_root_path}/${test_folder_path}"
    source "${xpack_root_path}/scripts/xmake-test-${test_name}.sh" $@
  done
}

# xmake tests [--target <name>] [--toolchain <name>]
do_xmake() {
  if [ $# -lt 1 ]
  then
    do_xmake_help
    exit 1
  fi

  case "$1" in
    tests)
      shift
      do_xmake_tests $@
      return 0
      ;;

    test)

      return 0
      ;;

    build)

      ;;
  esac

  echo "$@ not implemented"
  return 1
}

# -----------------------------------------------------------------------------
