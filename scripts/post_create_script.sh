#!/bin/bash

git config --global --add safe.directory '*'

if ! command -v click-odoo-update &>/dev/null; then
  cd /workspace/odoo || exit 0
  pip install -e . click-odoo-contrib
fi

if ! command -v checklog-odoo &>/dev/null; then
  cd /workspace/odoo || exit 0
  pip install checklog-odoo
fi
