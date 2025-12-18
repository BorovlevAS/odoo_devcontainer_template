#!/bin/sh

CURRENT_DIR=$(basename "$PWD")
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "COMPOSE_PROJECT_NAME=$CURRENT_DIR" >"$ENV_FILE"
else
    if ! awk -F= '/^COMPOSE_PROJECT_NAME=/{exit !($2)}' "$ENV_FILE"; then
        if grep -q "^COMPOSE_PROJECT_NAME=" "$ENV_FILE"; then
            sed -i'' -e "/^COMPOSE_PROJECT_NAME=/c\COMPOSE_PROJECT_NAME=$CURRENT_DIR" "$ENV_FILE"
        else
            echo "COMPOSE_PROJECT_NAME=$CURRENT_DIR" >>"$ENV_FILE"
        fi
    fi
fi

if [ ! -d ".vscode-server" ]; then
    mkdir .vscode-server
fi

if [ ! -d ".vscode-server-insiders" ]; then
    mkdir .vscode-server-insiders
fi

if [ ! -d "$HOME/.ssh" ]; then
    echo "Creating folder ~/.ssh"
    mkdir -p "$HOME/.ssh"
fi

if [ ! -d ".vscode" ]; then
    mkdir .vscode
fi

if [ -d ".vscode" ]; then
    if [ ! -f ".vscode/launch.json" ]; then
        cp scripts/templates/launch.template .vscode/launch.json
    fi
    if [ ! -f ".vscode/settings.json" ]; then
        cp scripts/templates/settings.template .vscode/settings.json
    fi
    if [ ! -f ".vscode/tasks.json" ]; then
        cp scripts/templates/tasks.template .vscode/tasks.json
    fi
fi

if [ ! -f "conf/odoo-server.conf" ]; then
    cp scripts/templates/odoo-server.conf.template conf/odoo-server.conf
fi

if [ ! -d "scripts_local" ]; then
    mkdir scripts_local
    cp scripts/template_scripts/*.sh scripts_local/
fi

if [ ! -d "temp" ]; then
    mkdir temp
fi

if [ ! -d "db_backup" ]; then
    mkdir db_backup
fi

if [ ! -f .odoo-version ]; then
  echo ".odoo-version file not found"
  exit 1
fi

ODOO_VERSION=$(cat .odoo-version)

if [ ! -d odoo/.git ]; then
  echo "Using Odoo version: ${ODOO_VERSION}"
  git clone -b ${ODOO_VERSION} --depth=1 https://github.com/odoo/odoo.git odoo
fi

docker pull borovlevas/odoo-base:14.0
