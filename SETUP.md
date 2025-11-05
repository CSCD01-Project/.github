# Cloudflare D1 Development Environment Setup

This guide is for setting up the development environment for the Cloudflare D1 Database integration with Apache Superset. It covers cloning all repositories, setting up Python, and installing dependencies.

### 0. Installation Requirements

This project assumes you already have `poetry` and `pyenv` with python `3.11.13` installed. If not:

##### [PyEnv Install Instructions](https://github.com/pyenv/pyenv?tab=readme-ov-file#installation)
##### Install correct python version
```bash
pyenv install 3.11.13
```
##### Install Poetry
```bash
curl -sSL https://install.python-poetry.org | python3 -
exec $SHELL
poetry --version ```

---


### 1. Create a main project directory

Choose a location to hold both projects (change for your system):

```bash
mkdir -p ~/dev/d01-project
cd ~/dev/d01-project
```

After this, all repositories will live under this folder.

---

### 1.5 Setup Script

The setup script found in [SETUP.sh](./SETUP.sh) will automatically execute steps 2-6 **in the current working directory**. It requires you to:
1. Have CLI logged into github with ssh access set up (`git clone git@github.com:...` works)
2. Have all dependencies in step 0 installed.

```bash
cd ~/dev/d01-project # Ensure you are in correct working directory

# Using curl
source <(curl -sSL https://raw.githubusercontent.com/CSCD01-Project/.github/refs/heads/main/setup.sh)

# Using wget
source <(wget -qO- https://raw.githubusercontent.com/CSCD01-Project/.github/refs/heads/main/setup.sh)
```

---

### 2. Clone repos

```bash
git clone git@github.com:CSCD01-Project/dbapi-d1.git
git clone git@github.com:CSCD01-Project/sqlalchemy-d1.git
git clone git@github.com:CSCD01-Project/superset-engine-d1.git
```

Directory structure after cloning:

```
d01-project/
 ├── superset-engine-d1/
 ├── dbapi-d1/
 └── sqlalchemy-d1/
```

---

### 3. Install dependencies with Poetry

For each repository:

```bash
cd ~/dev/d01-project/dbapi-d1
poetry env activate
poetry install

cd ../sqlalchemy-d1
poetry env activate
poetry install
poetry build

cd ../superset-engine-d1
poetry env activate
poetry install
```

This will create a virtual environment for each project and install all dependencies.

---

### 4. Verify dependency linkage

From `sqlalchemy-d1`:

```bash
poetry show dbapi-d1
```

It should display the local path (`../dbapi-d1`) and confirm it is editable.

From `superset-engine-d1`

```bash
poetry show 
```

It should display `../sqlalchemy-d1` in the dependency list.

---

### 5. Setting up Superset

You are able to run superset directly from the `superset-engine-d1` repository. 

First, you will need to create `.env` and `superset_config.py` files in the root, with a secure key.

```env
# superset-engine-d1/.env
FLASK_APP=superset.app:create_app()
```

```env
# superset-engine-d1/superset_config.py
SECRET_KEY = "<generate secure key>"
SQLALCHEMY_DATABASE_URI = "sqlite:////tmp/superset.db"
```

Then you will need to run a few setup steps. These initialize superset.

```bash
export SUPERSET_CONFIG_PATH="$(pwd)/superset_config.py"
poetry run superset db upgrade
poetry run superset fab create-admin \
    --username admin \
    --firstname Superset \
    --lastname Admin \
    --email admin@example.com \
    --password admin
poetry run superset init
```

After this, you can run the superset server

### 6. Running Superset

```bash
export SUPERSET_CONFIG_PATH="$(pwd)/superset_config.py"
poetry run superset run -p 8088 --with-threads --reload --debugger
```

> [!IMPORTANT]
> Remember that any time you start in a new shell, you will need to run `export SUPERSET_CONFIG_PATH="$(pwd)/superset_config.py"` again, or the server will not work.

### 7. Connecting Superset to D1

> [!NOTE]
> This step requires you to have an active Cloudflare account with a D1 database. You will need the following:
> 1. Your Cloudflare ACCOUNT_ID
> 2. A [Cloudflare access token](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/) with D1 read permissions.
> 3. Your D1 Database D1_DB_ID
> 4. The database should be populated with some sample data. You can directly access the SQL console for the database from the Cloudflare D1 dashboard for it. You can run `CREATE TABLE` and `INSERT` commands accordingly.

Opening the local superset server, follow these steps:
1. Login with credentials (user and password both `admin`, assuming you followed above)
2. Click `Settings -> Database Connections` in top-right corner
3. Click `+ Database` in top-right corner
4. `Choose a database -> Other`
5. Fill in URL with the following format: `d1://<CF_ACCOUNT_ID>:<CF_API_TOKEN>@<D1_DB_ID>`
6. Click test connection and make sure it works. Then click connect.
7. Click `+ -> Data -> Create Dataset` in top-right corner
8. `Database -> D1`, `Schema -> Main`, `Table -> <your table>`
9. Select a chart that applies for your data. It should preview accordingly.

If everything works, the setup was successful. If anything breaks, check the logs for the server.

---

### 8. Running Tests

The `client` repository is configured with a `main` script intended to test basic functionality. You can use this to ensure the packages are working correctly. You will need to create a D1 Database, run the SQL commands provided in the comments at the top of `main.py`, and add the appropriate credentials to a `.env` file.

```bash
git clone git@github.com:CSCD01-Project/client.git
cd client
poetry env activate
poetry install
touch .env # Add credentials
poetry run client
```

> [!WARNING]
> To run the main script, you must do so **through poetry**. Running with `python src/client/main.py` on its own will not correctly resolve the packages.

This is a temporary repository. We should aim to fully replace this testing, and add a lot more, with appropriate individual unit tests in each respository.

### Misc

> [!TODO]
> Tests are not yet written, these will come later on

Run tests with:

```bash
poetry run pytest
```

> [!NOTE]
> Make sure editors/IDEs use the Poetry-managed virtual environment for linting and execution.
