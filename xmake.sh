#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------

script=$0
if [[ "${script}" != /* ]]
then
  # Make relative path absolute.
  script=$(pwd)/$0
fi

parent="$(dirname ${script})"
# echo $parent

# -----------------------------------------------------------------------------
# Until the xmake-js tool will be functional, use this Bash script
# to build and test xPacks.
# -----------------------------------------------------------------------------

xpack_helper_path="${parent}/xpack-helper.sh"

source  "${xpack_helper_path}"


# -----------------------------------------------------------------------------

do_xmake_test_begin() {

  echo "Starting test \"${test_name}\", target=\"${target_name}\", toolchain=\"${toolchain_name}\", profile \"${profile_name}\"..."
  echo
  
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

  echo "C options: \"${c_opts}\""
  echo "C++ options: \"${cpp_opts}\""

  # Concatenate a list of absolute include paths.
  include_paths=""
  for f in ${include_folders[@]}
  do
    include_paths="${include_paths} -I\"${xpack_root_path}/${f}\""
  done

  # Create the output source folders, where to generate make pieces.
  for f in ${src_folders[@]}
  do
    mkdir -pv "${build_folder_absolute_path}/${f}"
  done

}

do_xmake_test_end() {

  echo
  echo "Test \"${test_name}\", target=\"${target_name}\", toolchain=\"${toolchain_name}\", profile \"${profile_name}\" completed successfuly."
  echo
}

# ${build_folder_path}
# ${build_folder_absolute_path}
# ${artifact_name}
# ${src_folders[@]}

do_xmake_create_makefile() {

  echo
  echo "Creating \"${build_folder_path}/makefile\"..."
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ tab }}|${tab}|g" | \
  sed -e "s|{{ artifact_name }}|${artifact_name}|g" | \
  cat > "${build_folder_absolute_path}/makefile"
################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../../makefile.init

RM := rm -rf

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
  sed -e "s|{{ artifact_name }}|${artifact_name}|g" | \
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

# All Target
all: {{ artifact_name }}

# Tool invocations
{{ artifact_name }}: $(OBJS) $(USER_OBJS)
{{ tab }}@echo ' '
{{ tab }}@echo 'Building target: $@'
{{ tab }}@echo 'Invoking: GCC C++ Linker'
{{ tab }}g++  -o "{{ artifact_name }}" $(OBJS) $(USER_OBJS) $(LIBS)
{{ tab }}@echo 'Finished building target: $@'

# Other Targets
clean:
{{ tab }}-@echo ' '
{{ tab }}-$(RM) $(CC_DEPS)$(C++_DEPS)$(C_UPPER_DEPS)$(CXX_DEPS)$(CPP_DEPS)$(C_DEPS) 
{{ tab }}-$(RM) $(EXECUTABLES) $(OBJS) {{ artifact_name }}

.PHONY: all clean dependents
.SECONDARY:

-include ../../makefile.targets
__EOF__
# The above marker must start in the first column.

}


do_xmake_create_objects() {

  echo "Creating \"${build_folder_path}/objects.mk\"..."
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


do_xmake_create_sources() {

  echo "Creating \"${build_folder_path}/sources.mk\"..."
  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ artifact_name }}|${artifact_name}|g" | \
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
do_xmake_create_subdir() {
  
  local folder=$1

  echo "Creating \"${build_folder_path}/${folder}/subdir.mk\"..."
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
    echo "C_SRCS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${c_files[@]}
    do
      echo "../../${folder}/${f}.c \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"

    echo "C_DEPS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${c_files[@]}
    do
      echo "./${folder}/${f}.d \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"

    echo "OBJS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${c_files[@]}
    do
      echo "./${folder}/${f}.o \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"
  fi

  if [ ${#cpp_files[@]} -gt 0 ]
  then
    echo "CPP_SRCS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${cpp_files[@]}
    do
      echo "../../${folder}/${f}.cpp \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"

    echo "CPP_DEPS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${cpp_files[@]}
    do
      echo "./${folder}/${f}.d \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"

    echo "OBJS += \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    for f in ${cpp_files[@]}
    do
      echo "./${folder}/${f}.o \\" >> "${build_folder_absolute_path}/${folder}/subdir.mk"
    done
    echo >> "${build_folder_absolute_path}/${folder}/subdir.mk"
  fi

  # Note: EOF is quoted to prevent substitutions here.
  cat <<'__EOF__' | \
  sed -e "s|{{ tab }}|${tab}|g" | \
  sed -e "s|{ artifact_name }}|${artifact_name}|g" | \
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
{{ tab }}gcc {{ c_opts }} -c -fmessage-length=0 {{ include_paths }} -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
{{ tab }}@echo 'Finished building: $<'

{{ folder }}/%.o: ../../{{ folder }}/%.cpp
{{ tab }}@echo ' '
{{ tab }}@echo 'Building file: $<'
{{ tab }}@echo 'Invoking: GCC C++ Compiler'
{{ tab }}g++ {{ cpp_opts }} -c -fmessage-length=0 {{ include_paths }} -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
{{ tab }}@echo 'Finished building: $<'

__EOF__
# The above marker must start in the first column.

}

# -----------------------------------------------------------------------------

# Forward the args to the helper.
do_xmake $@

# -----------------------------------------------------------------------------
