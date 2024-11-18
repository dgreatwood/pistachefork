#!/bin/bash

#
# SPDX-FileCopyrightText: 2024 Duncan Greatwood
#
# SPDX-License-Identifier: Apache-2.0
#

# This script test the homebrew formula for Pistache. It will copy the
# local brew formula, pistache.rb, to the brew repo directory and
# install it in macOS

# Documentation: https://docs.brew.sh/Adding-Software-to-Homebrew
#                https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# Also:
#  https://docs.github.com/en/repositories/releasing-projects-on-github/
#      managing-releases-in-a-repository
#
#  And to make a sha-256 from a release, Go to Pistache home page ->
#  Releases and download the tarball for the release. Then:
#    shasum -a 256 <filename.tar.gz>
#  Note: brew formula audit prefers tarball to zip file.

if [ $# -gt 0 ]; then
    if [ $# -gt 1 ] || [ "$1" != "--HEAD" ]; then
        echo "Usage: $(basename "$0") [-h] [--help] [--HEAD]"
        echo "       With --HEAD, tests with head of pistache master"
        echo "       Otherwise, tests with pistache release"
        exit 0
    fi
fi

if ! type "brew" > /dev/null; then
    echo "brew not found; brew is required to proceed"
    exit 1
fi

export HOMEBREW_NO_INSTALL_FROM_API=1

if hbcore_repo=$(brew --repository homebrew/core); then
    if [ ! -d "$hbcore_repo" ]; then
        echo "Cloning homebrew/core to $hbcore_repo"
        brew tap --force homebrew/core
    fi
else
    echo "Cloning homebrew/core"
    brew tap --force homebrew/core
    if ! hbcore_repo=$(brew --repository homebrew/core); then
        echo "Failed to find homebrew/core repo"
        exit 1
    fi
fi

pist_form_dir="$hbcore_repo/Formula/p"
if [ ! -d "$pist_form_dir" ]; then
    echo "Failed to find homebrew/core formula dir $pist_form_dir"
    exit 1
fi
pist_form_file="$pist_form_dir/pistache.rb"

MY_SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$pist_form_file" ]; then

    if cmp --silent -- "$MY_SCRIPT_DIR/pistache.rb" "$pist_form_file"; then
        echo "$pist_form_file is already up to date, exiting"
        if [ "$1" != "--HEAD" ]; then
            if brew list pistache &>/dev/null; then
                echo "If you like: brew remove pistache; brew install --build-from-source pistache"
            else
                echo "If you like: brew install --build-from-source pistache"
            fi
        else
            if brew list pistache &>/dev/null; then
                echo "If you like: brew remove pistache; brew install --HEAD pistache"
            else
                echo "If you like: brew install --HEAD pistache"
            fi
        fi
        exit 0
    fi

    pist_form_bak="$MY_SCRIPT_DIR/pistache.rb.bak"
    echo "Overwriting $pist_form_file"
    echo "Saving prior to $pist_form_bak"
    cp "$pist_form_file" "$pist_form_bak"
    cp "$MY_SCRIPT_DIR/pistache.rb" "$pist_form_file"
else
    echo "Copying pistache.rb to $pist_form_dir/"
    cp "$MY_SCRIPT_DIR/pistache.rb" "$pist_form_file"
fi

if brew list pistache &>/dev/null; then brew remove pistache; fi
if [[ "$1" == "--HEAD" ]]; then
    brew install --HEAD pistache
else
    brew install --build-from-source pistache
fi
brew test --verbose pistache

read -e -p 'brew audit? [y/N]> '
if [[ "$REPLY" == [Yy]* ]]; then
    brew audit --strict --new --online pistache
else
    echo "Skipping audit"
fi
