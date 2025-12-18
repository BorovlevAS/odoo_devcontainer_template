# Odoo DevContainer Template

## Description

A ready-to-use development environment template for Odoo 17.0 using VS Code DevContainers. Includes all necessary tools, configurations, and dependencies for Odoo development.

**Key Features:**
- Odoo 17.0 (automatically cloned during initialization)
- PostgreSQL 14.13
- Base Docker image `borovlevas/odoo-base:17.0`
- VS Code DevContainer with pre-configured extensions
- Automated initialization and setup scripts
- Development tools (debugger, linters, formatters)
- click-odoo utilities for database management

## Prerequisites

- Docker and Docker Compose
- Visual Studio Code with "Dev Containers" extension
- Git

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd odoo_devcontainer_template
   ```

2. **Open in VS Code:**
   ```bash
   code .
   ```

3. **Open in DevContainer:**
   - Press `F1` or `Ctrl+Shift+P`
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and initialize

   **What happens on first launch:**
   - Creates `.env` file with project name (from directory name)
   - Clones Odoo 17.0 repository into `odoo/` folder
   - Creates necessary directories (`.vscode-server`, `temp`, `db_backup`, `scripts_local`)
   - Copies VS Code configuration templates (if they don't exist)
   - Installs `click-odoo-contrib` and `checklog-odoo` packages
   - Pulls base Docker image

4. **Start Odoo:**
   ```bash
   cd /workspace
   python3 odoo/odoo-bin -c conf/odoo-server.conf
   ```
   
   Or use VS Code debugger (see "Debugging" section)

5. **Access Odoo:**
   - Open in browser: `http://localhost:8069`

## Project Structure

```
.
├── .devcontainer/             # DevContainer configuration
│   ├── devcontainer.json     # Main configuration
│   └── docker-compose.yml    # Additional container parameters
├── conf/                      # Odoo and PostgreSQL configuration
│   ├── odoo-server.conf      # Main Odoo configuration
│   └── postgres/             # PostgreSQL settings
│       ├── postgresql.conf
│       └── pg_hba.conf
├── docker/                    # Docker files
│   ├── Dockerfile            # Odoo container image (based on borovlevas/odoo-base:18.0)
│   └── docker-compose.yml    # Services orchestration (odoo + db)
├── odoo/                      # Odoo 18.0 source code (cloned automatically)
├── scripts/                   # Initialization scripts
│   ├── initialize_script.sh  # Runs before container creation
│   ├── post_create_script.sh # Runs after container creation
│   ├── templates/            # VS Code configuration templates
│   │   ├── launch.template
│   │   ├── settings.template
│   │   ├── tasks.template
│   │   └── odoo-server.conf.template
│   └── template_scripts/     # Local script templates
│       ├── run_tests.sh
│       ├── update_db.sh
│       └── update_repo_and_db.sh
├── scripts_local/             # Local scripts (created automatically)
├── varlib/                    # Odoo data (filestore, sessions)
├── db_backup/                 # Database backups
├── temp/                      # Temporary files
├── .env                       # Environment variables (created automatically)
├── .odoo-version              # Odoo version (18.0)
└── .vscode/                   # VS Code settings (created automatically)
    ├── launch.json
    ├── settings.json
    └── tasks.json
```

## Configuration

### Odoo

Main configuration file: `conf/odoo-server.conf`

**Important parameters:**
- `addons_path`: `/workspace/odoo,/workspace/odoo/addons` (you can add custom paths)
- `data_dir`: `/workspace/varlib` (file storage)
- `db_host`: `db` (PostgreSQL service name)
- `admin_passwd`: Hashed master password
- `workers`: `0` (for development mode)
- `gevent_port`: `8072` (longpolling)

### Database

**Connection parameters:**
- **Host:** `db` (inside container) / `localhost` (from host)
- **Port:** `5432`
- **User:** `odoo`
- **Password:** `odoo`
- **Database:** `postgres` (default)

### Ports

- **8069:** Odoo web interface
- **8072:** Longpolling (for chat and notifications)

### Environment Variables

The `.env` file is created automatically during initialization:
```bash
COMPOSE_PROJECT_NAME=<directory_name>
```

## Development Workflow

### Installing Additional Python Packages

1. Create a requirements file (e.g., `extra_addons/extra_requirements.txt`)
2. Uncomment and edit in `docker/Dockerfile`:
   ```dockerfile
   COPY extra_addons/extra_requirements.txt /tmp/extra_requirements.txt
   RUN pip3 install --no-cache-dir -r /tmp/extra_requirements.txt
   ```
3. Rebuild container: `Dev Containers: Rebuild Container`

### Adding Custom Addons

1. Create a directory for addons (e.g., `extra_addons/`)
2. Add path to `conf/odoo-server.conf`:
   ```ini
   addons_path = /workspace/odoo,
       /workspace/odoo/addons,
       /workspace/extra_addons
   ```

### Debugging

DevContainer includes pre-configured debug configuration in `.vscode/launch.json`:

**"Python: Debug Odoo" configuration:**
- Launches `odoo-bin` with configuration from `conf/odoo-server.conf`
- Enables `--dev=xml` mode (automatic view reloading)
- Uses integrated terminal

**How to use:**
1. Set breakpoints in your code
2. Press `F5` or select "Run" → "Start Debugging"
3. Odoo will start in debug mode

### Database Management

After initialization, utilities are available in `scripts_local/`:

**`update_db.sh`** - Update database:
```bash
./scripts_local/update_db.sh
```
Uses `click-odoo-update` to update modules in `devdb` database.

**`run_tests.sh`** - Run tests:
```bash
./scripts_local/run_tests.sh yes tests_db
```
Parameters:
- `yes`/`no` - whether to drop database before tests
- Database name for testing

**`update_repo_and_db.sh`** - Update repository and database:
```bash
./scripts_local/update_repo_and_db.sh
```
Updates all submodules and runs database update.

### click-odoo Utilities

Installed utilities:
- `click-odoo-update` - update modules
- `click-odoo-dropdb` - drop database
- `click-odoo-backupdb` - backup database
- `click-odoo-restoredb` - restore from backup
- `checklog-odoo` - analyze Odoo logs

## VS Code Extensions

DevContainer includes the following extensions:

**Python:**
- `ms-python.python` - Python support
- `ms-python.vscode-pylance` - Advanced language server
- `ms-python.debugpy` - Debugger
- `ms-python.black-formatter` - Code formatting
- `ms-python.flake8` - Linter
- `ms-python.isort` - Import sorting
- `ms-python.pylint` - Linter
- `donjayamanne.python-environment-manager` - Environment management

**Odoo:**
- `trinhanhngoc.vscode-odoo` - Odoo development support

**Git:**
- `donjayamanne.git-extension-pack` - Git extensions pack
- `mhutchie.git-graph` - Git history visualization
- `donjayamanne.githistory` - File history

**Database:**
- `mtxr.sqltools` - SQL client
- `mtxr.sqltools-driver-pg` - PostgreSQL driver

**Utilities:**
- `janisdd.vscode-edit-csv` - CSV editor
- `mechatroner.rainbow-csv` - CSV highlighting
- `redhat.vscode-xml` - XML support
- `formulahendry.auto-close-tag` - Auto close tags
- `formulahendry.auto-rename-tag` - Auto rename tags
- `yzhang.markdown-all-in-one` - Markdown tools
- `IBM.output-colorizer` - Output highlighting
- `mrorz.language-gettext` - gettext support
- `esbenp.prettier-vscode` - Formatting (XML)
- `huuums.vscode-fast-folder-structure` - Fast folder structure creation

**Python Settings:**
- Default interpreter: `/opt/odoo/venv/bin/python`
- Prettier for XML file formatting

## Troubleshooting

### Container Fails to Start

1. Ensure Docker is running
2. Check if ports 8069 and 8072 are available:
   ```bash
   sudo lsof -i :8069
   sudo lsof -i :8072
   ```
3. Check container logs:
   ```bash
   docker-compose -f docker/docker-compose.yml logs
   ```

### Empty odoo/ Directory

The Odoo repository is cloned automatically during first initialization. If cloning didn't happen:

```bash
# Remove directory
rm -rf odoo

# Rebuild container
# VS Code: Dev Containers: Rebuild Container
```

Or clone manually:
```bash
git clone -b 17.0 --depth=1 https://github.com/odoo/odoo.git odoo
```

### Package Installation Errors

If `click-odoo-contrib` or other packages failed to install:

```bash
cd /workspace/odoo
pip install -e . click-odoo-contrib checklog-odoo
```

### Permission Issues

The initialization script automatically configures necessary directories. If issues occur:

```bash
git config --global --add safe.directory '*'
```

### Ports Already in Use

Change ports in `docker/docker-compose.yml`:
```yaml
ports:
  - "8069:8069"  # Change first number, e.g.: "8070:8069"
  - "8072:8072"  # Change first number, e.g.: "8073:8072"
```

## Project Customization

The template is easily adaptable for specific projects:

### Changing Odoo Version

1. Edit `.odoo-version` file:
   ```bash
   echo "18.0" > .odoo-version
   ```

2. Update base image in `docker/Dockerfile`:
   ```dockerfile
   FROM borovlevas/odoo-base:18.0
   ```

3. Rebuild container

### Adding Custom Modules

1. Create modules directory:
   ```bash
   mkdir -p client_addons/my_module
   ```

2. Update `conf/odoo-server.conf`:
   ```ini
   addons_path = /workspace/odoo,
       /workspace/odoo/addons,
       /workspace/client_addons
   ```

### Configuring Git Submodules

If you need to work with submodules (e.g., OCA modules):

1. Add submodule:
   ```bash
   git submodule add -b 17.0 https://github.com/OCA/web.git external_addons/web
   ```

2. Update `.gitmodules` with branch specification:
   ```ini
   [submodule "external_addons/web"]
       path = external_addons/web
       url = https://github.com/OCA/web.git
       branch = 17.0
   ```

3. Add path to Odoo configuration

### Customizing Initialization Scripts

Edit:
- `scripts/initialize_script.sh` - runs before container creation
- `scripts/post_create_script.sh` - runs after container creation

---

## Additional Information

**Base Image:** `borovlevas/odoo-base:17.0`
- Includes all Odoo 17.0 dependencies
- Python 3.11
- wkhtmltopdf for PDF generation
- Node.js and npm for frontend tools

**Odoo Version:** 17.0  
**PostgreSQL Version:** 14.13

Ensure your custom modules are compatible with Odoo 17.0.
