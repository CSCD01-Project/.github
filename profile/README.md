# CSCD01 Project – Cloudflare D1 Integration with Apache Superset

Welcome to the **CSCD01 Project** organization! This organization hosts all repositories related to integrating **Cloudflare D1** databases with **Apache Superset**, including the custom DBAPI driver, SQLAlchemy dialect, and Superset engine specifications.

---

## Repositories

| Repository | Description |
|------------|-------------|
| `dbapi-d1` | Cloudflare D1 DBAPI 2.0 driver implementation. Handles communication with D1 via the Cloudflare API. |
| `sqlalchemy-d1` | SQLAlchemy dialect for D1. Provides SQLAlchemy compatibility, reflection, and column type mapping. |
| `superset-engine-d1` | Superset EngineSpec for D1. Integrates the D1 dialect into Superset, enabling datasets, charts, and dashboards. |
| `client` | Temporary test client for verifying DBAPI and engine functionality. |

---

## Project Structure

```
d01-project/
├── dbapi-d1/
├── sqlalchemy-d1/
├── superset-engine-d1/
└── client/
```

Each repository is independent, uses **Poetry** for dependency management, and contains its own virtual environment.

## Project Setup

Setup instructions can be found in [SETUP.md](../SETUP.md).

---

## Development Notes

* The `D1Dialect` in `sqlalchemy-d1` handles schema reflection and type mapping for D1.
* `superset-engine-d1` exposes `D1EngineSpec` for Superset.
* DBAPI operations are implemented in `dbapi-d1`. Always use **parameterized queries** to avoid injection issues.

---

## Contributing

1. Fork the relevant repository.
2. Create a feature branch.
3. Write tests for new functionality.
4. Submit a pull request.

Please follow **PEP8**, **Poetry dependency management**, and Superset coding conventions.

---

## License

All repositories in this organization are licensed under the **Apache License 2.0**.

---

## Contact

For questions or support, reach out to:

* [**Chad Rossouw**](https://github.com/ChadRosseau)
* [**Murphy Lee**](https://github.com/murphylee10)
* [**Shreyas Rao**](https://github.com/ThunderRoar)
* [**Daniel Alyoshin**](https://github.com/danielalyoshin)
* [**Alan Zhang**](https://github.com/jang-35)
