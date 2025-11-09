#!/bin/bash
if ! command -v click-odoo-update &>/dev/null; then
  echo "The 'click-odoo-update' command is not available. Please install click-odoo-contrib package."
else
  click-odoo-update -c conf/odoo-server.conf -d devdb --log-level=error
fi
