# Odoo DevContainer Template

## Purpose

This repository provides a ready-to-use development environment template for Odoo 14.0 using VS Code DevContainers. It enables developers to quickly set up a fully configured Odoo development environment with all necessary dependencies, tools, and configurations pre-installed.

**Key Features:**
- Odoo 14.0 as a Git submodule
- PostgreSQL 12.18 database
- Pre-configured Docker environment
- VS Code DevContainer support with essential extensions
- Automated initialization and setup scripts
- Development tools (debugger, linters, formatters)

## Usage

### Prerequisites

- Docker and Docker Compose installed
- Visual Studio Code with the Remote - Containers extension
- Git configured with SSH access to GitHub (for Odoo submodule)

### Getting Started

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd odoo_devcontainer_template
   ```

2. **Initialize the Odoo submodule:**
   ```bash
   git submodule update --init --recursive
   ```

3. **Open in VS Code:**
   ```bash
   code .
   ```

4. **Open in DevContainer:**
   - Press `F1` or `Ctrl+Shift+P`
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and initialize

5. **Start Odoo:**
   - Open a terminal in VS Code
   - Run:
     ```bash
     odoo-bin -c /etc/odoo/odoo-server.conf
     ```
   - Access Odoo at `http://localhost:8069`

### Project Structure

```
.
├── .devcontainer/          # DevContainer configuration
├── conf/                   # Odoo and PostgreSQL configurations
│   ├── odoo-server.conf   # Main Odoo configuration file
│   └── postgres/          # PostgreSQL settings
├── docker/                 # Docker setup files
│   ├── Dockerfile         # Odoo container image
│   └── docker-compose.yml # Services orchestration
├── odoo/                   # Odoo source code (Git submodule)
├── scripts/                # Initialization and setup scripts
│   ├── initialize_script.sh
│   ├── post_create_script.sh
│   └── templates/         # VS Code configuration templates
├── .local/                 # Odoo data directory
├── db_backup/             # Database backups location
└── temp/                  # Temporary files
```

### Configuration

#### Odoo Configuration
Edit `conf/odoo-server.conf` to customize:
- Database connection settings
- Addons paths
- Server parameters
- Performance limits

#### Database Access
- **Host:** `db` (within container) or `localhost` (from host)
- **Port:** `5432`
- **User:** `odoo`
- **Password:** `odoo`
- **Database:** `postgres`

#### Ports
- **8069:** Odoo web interface
- **8072:** Odoo longpolling

### Development Workflow

#### Installing Additional Python Packages
Uncomment and edit in `docker/Dockerfile`:
```dockerfile
COPY extra_addons/extra_requirements.txt /tmp/extra_requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/extra_requirements.txt
```

#### Adding Custom Addons
Add your custom addon paths to `conf/odoo-server.conf`:
```ini
addons_path = /workspace/odoo,
    /workspace/odoo/addons,
    /workspace/extra_addons
```

#### Debugging
The DevContainer comes with pre-configured launch configurations in `.vscode/launch.json` for debugging Odoo.

#### Database Management
Local scripts are available in `scripts_local/` for common database operations (created during initialization).

### VS Code Extensions

The DevContainer includes pre-installed extensions:
- **Python:** Black, Flake8, isort, Pylint, Pylance
- **Odoo:** Odoo development support
- **Git:** Git Graph, Git History
- **Database:** SQLTools with PostgreSQL driver
- **Utilities:** CSV editor, XML support, Markdown tools

### Troubleshooting

**Container fails to start:**
- Ensure Docker is running
- Check if ports 8069 and 8072 are available

**Odoo submodule is empty:**
```bash
git submodule update --init --recursive
```

**Permission issues:**
The initialization script handles common permission setup automatically.

### Customization

This template is designed to be extended. You can:
- Modify the base image in `docker/Dockerfile`
- Add environment-specific configurations
- Customize initialization scripts in `scripts/`
- Add project-specific VS Code settings

---

**Note:** This template uses Odoo 14.0. Make sure your custom addons are compatible with this version.
