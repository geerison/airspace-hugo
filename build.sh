#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ASSET_DIRNAME="assets"
STATIC_DIRNAME="static"
THEMES_DIRNAME="themes"

source "${ROOT_DIR}/build_config.sh"

REQUIRED_COMMANDS=(
	"hugo"
	"cjpeg"
	"uglifycss"
	"uglifyjs"
	"pngout" )

function check_hugo_version {
	version_string=$(hugo version)
	version_string=${version_string#* v}
	version_string=${version_string%% *}

	if [ "${version_string}" != "${HUGO_VERSION}" ]; then
		echo "Hugo is v${version_string} but we expected v${HUGO_VERSION}."
		return  1
	fi

	return 0
}

function build_themes {
	theme_dir="${1}"

	for theme in $theme_dir/*; do
		if [ -d "${theme}" ]; then
			build_folder "${theme}/${ASSET_DIRNAME}" "${theme}/${STATIC_DIRNAME}"
		fi
	done
}

function build_folder {
	input_dir="${1}"
	output_dir="${2}"

	rm -rf "${output_dir}"
	mkdir "${output_dir}"

	process_folder "${input_dir}" "${input_dir}" "${output_dir}"
}

function process_folder {
	local current_dir="${1}"
	local input_dir="${2}"
	local output_dir="${3}"

	for file in $current_dir/* $current_dir/.*; do
		if [ "${file}" != "${current_dir}/." ] && [ "${file}" != "${current_dir}/.." ]; then
			if [ -d "${file}" ]; then
				process_folder "${file}" "${input_dir}" "${output_dir}"
			elif [ -f "${file}" ]; then
				process_file "${file}" "${input_dir}" "${output_dir}"
			fi
		fi
	done
}

function process_file {
	input_file="${1}"
	input_dir="${2}"
	output_dir="${3}"

	ext="${input_file##*.}"

	output_file=${input_file/$input_dir/$output_dir}
	output_file_noext="${output_file%.*}"

	input_file_short=${input_file/$input_dir/}
	output_file_short=${output_file/$output_dir/}

	input_file_dir=$(dirname "${input_file}")
	output_file_dir=$(dirname "${output_file}")

	# Create Directory
	mkdir -p "${output_file_dir}"

	# Process Files
	case "${ext}" in
		bmp)
			echo "Compressing \"${input_file_short}\""
			cjpeg -quality 85 -progressive -optimize -outfile "${output_file_noext}.jpg" "${input_file}"
			;;
		css)
			echo "Compressing \"${input_file_short}\""
			uglifycss "${input_file}" > "${output_file}"
			;;
		js)
			echo "Compressing \"${input_file_short}\""
			uglifyjs "${input_file}" > "${output_file}"
			;;
		png)
			echo "Compressing \"${input_file_short}\""
			pngout "${input_file}" "${output_file}" -q
			;;
		*)
			cp "${input_file}" "${output_file}"
			;;
	esac
}

function command_exists {
	cmd="${1}"
	if type "${cmd}" > /dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# Check for Required Functions
for cmd in "${REQUIRED_COMMANDS[@]}"; do
	if ! command_exists $cmd; then
		echo "Missing command ${cmd}. Terminating job."
		exit 1
	fi
done

# Check Hugo Version
if ! check_hugo_version; then
	exit 1
fi

# Build Site
build_folder "${ROOT_DIR}/${ASSET_DIRNAME}" "${ROOT_DIR}/${STATIC_DIRNAME}"
build_themes "${ROOT_DIR}/${THEMES_DIRNAME}"

hugo "$@"
