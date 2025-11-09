#!/bin/bash

git submodule foreach --recursive git reset --hard
git submodule foreach --recursive 'git fetch origin --tags && git checkout $(git config -f $toplevel/.gitmodules submodule.$name.branch || echo "main") && git pull'

pwd
bash ./scripts_local/update_database.sh
