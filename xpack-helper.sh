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

verbose=""

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
  echo "xmake tests [--target <name>] [--toolchain <name>] ... "
  echo "xmake test <name> [--target <name>] [--toolchain <name>] ..."
  echo "The command must be issued in the xPack root folder."
}


do_xmake_tests() {

  while [ $# -gt 0 ]
  do
    case "$1" in
      --verbose)
        shift
        verbose="y"
        ;;

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

      --)
        shift
        break
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

do_xmake_test() {

  test_name="$1"
  test_folder_path="tests/${test_name}"
  shift

  while [ $# -gt 0 ]
  do
    case "$1" in
      --verbose)
        shift
        verbose="y"
        ;;

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

      --)
        shift
        break
        ;;

      *)
        echo "Unsupported \"$1\", abort."
        exit 1
        ;;
    esac
  done

  cd "${xpack_root_path}/${test_folder_path}"
  if [ -f "test.json" ]
  then
    source "${xpack_root_path}/scripts/xmake-test-${test_name}.sh" $@
  fi
}

# xmake tests [--target <name>] [--toolchain <name>] ...
# xmake test <name> [--target <name>] [--toolchain <name>] ...

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
      shift 
      do_xmake_test $@
      return 0
      ;;

  esac

  echo "$@ not implemented"
  return 1
}

# -----------------------------------------------------------------------------

do_xmake_test_begin() {

  echo "Starting test \"${test_name}\", target=\"${target_name}\", toolchain=\"${toolchain_name}\", profile \"${profile_name}\"..."
  echo
  
  if [ "${toolchain_name}" == "gcc-6" ]
  then
    cmd_prefix=""
    cmd_suffix="-6"
  elif [ "${toolchain_name}" == "gcc-5" ]
  then
    cmd_prefix=""
    cmd_suffix="-5"
  else
    cmd_prefix=""
    cmd_suffix=""
  fi
  set +o nounset # do not Exit if variable not set.
  if [ -z ${c_cmd} ]
  then
    if [ "${toolchain_name}" == "clang" ]
    then
      c_cmd="${cmd_prefix}clang${cmd_suffix}"
    else
      c_cmd="${cmd_prefix}gcc${cmd_suffix}"
    fi
  fi
  if [ -z ${cpp_cmd} ]
  then
    if [ "${toolchain_name}" == "clang" ]
    then
      cpp_cmd="${cmd_prefix}clang++${cmd_suffix}"
    else
      cpp_cmd="${cmd_prefix}g++${cmd_suffix}"
    fi
  fi
  set -o nounset # Exit if variable not set.

  if [ "${verbose}" == "y" ]
  then

  echo -n "Source folders:"
  for f in "${src_folders[@]}"
  do
      echo -n " \"${f}\""
  done
  echo

  echo -n "Include folders:"
  for f in "${include_folders[@]}"
  do
      echo -n " \"${f}\""
  done
  echo

  echo "CC: \"${c_cmd}\""
  echo "CXX: \"${cpp_cmd}\""
  echo "CFLAGS: \"${c_opts}\""
  echo "CXXFLAGS: \"${cpp_opts}\""

  echo
  fi
  
  # Concatenate a list of absolute include paths.
  include_paths=""
  for f in ${include_folders[@]}
  do
    include_paths="${include_paths} -I\"${xpack_root_path}/${f}\""
  done

  # Create the output source folders, where to generate make pieces.
  for f in ${src_folders[@]}
  do
    if [ "${verbose}" == "y" ]
    then
      echo "Creating folder \"${build_folder_path}/${f}\"..."
    fi
    mkdir -p "${build_folder_absolute_path}/${f}"
  done
  # echo
}

do_xmake_test_end() {

  echo
  echo "Test \"${test_name}\", target=\"${target_name}\", toolchain=\"${toolchain_name}\", profile \"${profile_name}\" completed successfuly."
  echo
}

# -----------------------------------------------------------------------------

# ${build_folder_path}
# ${build_folder_absolute_path}
# ${artefact_name}
# ${src_folders[@]}

do_xmake_generate_makefile() {

  if [ "${verbose}" == "y" ]
  then
    echo
    echo "Generating file \"${build_folder_path}/makefile\"..."
  fi
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ tab }}|${tab}|g" | \
  sed -e "s|{{ cc }}|${c_cmd}|g" | \
  sed -e "s|{{ cxx }}|${cpp_cmd}|g" | \
  sed -e "s|{{ artefact_name }}|${artefact_name}|g" | \
  cat > "${build_folder_absolute_path}/makefile"
################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../../makefile.init

RM := rm -rf
CC := {{ cc }}
CXX := {{ cxx }}

# All Target
all: {{ artefact_name }}

# All of the sources participating in the build are defined here
-include sources.mk
__EOF__
# The above marker must start in the first column.

  for f in ${src_folders[@]}
  do
    echo "-include ${f}/subdir.mk" >>"${build_folder_absolute_path}/makefile"
  done

  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ tab }}|${tab}|g" | \
  sed -e "s|{{ artefact_name }}|${artefact_name}|g" | \
  cat >> "${build_folder_absolute_path}/makefile"
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(CC_DEPS)),)
-include $(CC_DEPS)
endif
ifneq ($(strip $(C++_DEPS)),)
-include $(C++_DEPS)
endif
ifneq ($(strip $(C_UPPER_DEPS)),)
-include $(C_UPPER_DEPS)
endif
ifneq ($(strip $(CXX_DEPS)),)
-include $(CXX_DEPS)
endif
ifneq ($(strip $(CPP_DEPS)),)
-include $(CPP_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# Tool invocations
{{ artefact_name }}: $(OBJS) $(USER_OBJS)
{{ tab }}@echo ' '
{{ tab }}@echo 'Building target: $@'
{{ tab }}@echo 'Invoking: GCC C++ Linker'
{{ tab }}$(CXX)  -o "{{ artefact_name }}" $(OBJS) $(USER_OBJS) $(LIBS)
{{ tab }}@echo 'Finished building target: $@'

# Other Targets
clean:
{{ tab }}-@echo ' '
{{ tab }}-$(RM) $(CC_DEPS)$(C++_DEPS)$(C_UPPER_DEPS)$(CXX_DEPS)$(CPP_DEPS)$(C_DEPS) 
{{ tab }}-$(RM) $(EXECUTABLES) $(OBJS) {{ artefact_name }}

.PHONY: all clean dependents
.SECONDARY:

-include ../../makefile.targets
__EOF__
# The above marker must start in the first column.

}


do_xmake_generate_objects() {

  if [ "${verbose}" == "y" ]
  then
    echo "Generating file \"${build_folder_path}/objects.mk\"..."
  fi
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  cat > "${build_folder_absolute_path}/objects.mk"
################################################################################
# Automatically-generated file. Do not edit!
################################################################################

USER_OBJS :=

LIBS :=
__EOF__
# The above marker must start in the first column.

}


do_xmake_generate_sources() {

  if [ "${verbose}" == "y" ]
  then
    echo "Generating file \"${build_folder_path}/sources.mk\"..."
  fi
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ artefact_name }}|${artefact_name}|g" | \
  cat > "${build_folder_absolute_path}/sources.mk"
################################################################################
# Automatically-generated file. Do not edit!
################################################################################

C_UPPER_SRCS := 
CXX_SRCS := 
OBJ_SRCS := 
C++_SRCS := 
CC_SRCS := 
ASM_SRCS := 
CPP_SRCS := 
C_SRCS := 
O_SRCS := 
S_UPPER_SRCS := 
CC_DEPS := 
C++_DEPS := 
EXECUTABLES := 
OBJS := 
C_UPPER_DEPS := 
CXX_DEPS := 
CPP_DEPS := 
C_DEPS := 

# Every subdirectory with source files must be described here
SUBDIRS := \
__EOF__
# The above marker must start in the first column.

  for f in ${src_folders[@]}
  do
    echo "${f} \\" >>"${build_folder_absolute_path}/sources.mk"
  done

  # Add an empty line, the previous lines are all continuing.
  echo  >>"${build_folder_absolute_path}/sources.mk"

}

# $1=relative path
do_xmake_generate_subdir() {
  
  local folder=$1

  if [ "${verbose}" == "y" ]
  then
    echo "Generating file \"${build_folder_path}/${folder}/subdir.mk\"..."
  fi
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  cat > "${build_folder_absolute_path}/${folder}/subdir.mk"
################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
__EOF__
# The above marker must start in the first column.

  if [ ${#c_files[@]} -gt 0 ]
  then
    for f in ${c_files[@]}
    do
      echo "C_SRCS += ../../${folder}/${f}.c" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
      echo "C_DEPS += ./${folder}/${f}.d" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
      echo "OBJS += ./${folder}/${f}.o" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
  fi

  if [ ${#cpp_files[@]} -gt 0 ]
  then
    for f in ${cpp_files[@]}
    do
      echo "CPP_SRCS += ../../${folder}/${f}.cpp" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
      echo "CPP_DEPS += ./${folder}/${f}.d" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
      echo "OBJS += ./${folder}/${f}.o" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
  fi

  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ tab }}|${tab}|g" | \
  sed -e "s|{ artefact_name }}|${artefact_name}|g" | \
  sed -e "s|{{ c_opts }}|${c_opts}|g" | \
  sed -e "s|{{ cpp_opts }}|${cpp_opts}|g" | \
  sed -e "s|{{ include_paths }}|${include_paths}|g" | \
  sed -e "s|{{ folder }}|${folder}|g" | \
  cat >> "${build_folder_absolute_path}/${folder}/subdir.mk"

# Each subdirectory must supply rules for building sources it contributes
{{ folder }}/%.o: ../../{{ folder }}/%.c
{{ tab }}@echo ' '
{{ tab }}@echo 'Building file: $<'
{{ tab }}@echo 'Invoking: GCC C Compiler'
{{ tab }}$(CC) {{ c_opts }} -c -fmessage-length=0 {{ include_paths }} -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
{{ tab }}@echo 'Finished building: $<'

{{ folder }}/%.o: ../../{{ folder }}/%.cpp
{{ tab }}@echo ' '
{{ tab }}@echo 'Building file: $<'
{{ tab }}@echo 'Invoking: GCC C++ Compiler'
{{ tab }}$(CXX) {{ cpp_opts }} -c -fmessage-length=0 {{ include_paths }} -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
{{ tab }}@echo 'Finished building: $<'

__EOF__
# The above marker must start in the first column.

}

# Scan folder for sources and call the create_subdir.
# $1=relative path

do_xmake_generate_subdir_scan() {

  declare -a c_files
  declare -a cpp_files

  pushd "../../$1" >/dev/null
  for f in *.c
  do
    # echo $f "${f%.*}"
    if [ "${f%.*}" != '*' ]
    then
      # Append file name without extension
      c_files[${#c_files[@]}]="${f%.*}"
    fi
  done

  for f in *.cpp
  do
    # echo $f  "${f%.*}"
    if [ "${f%.*}" != '*' ]
    then
      # Append file name without extension
      cpp_files[${#cpp_files[@]}]="${f%.*}"
    fi
  done
  popd >/dev/null
  
  do_xmake_generate_subdir "$1"
}

# -----------------------------------------------------------------------------

# Chain all 
do_xmake_generate() {

    # Root make files
  do_xmake_generate_makefile
  do_xmake_generate_objects
  do_xmake_generate_sources
  
  for f in "${src_folders[@]}"
  do
    do_xmake_generate_subdir_scan "${f}"
  done
}

# -----------------------------------------------------------------------------

