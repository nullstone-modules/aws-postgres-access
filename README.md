# aws-postgres-access

Nullstone capability to grant access for a postgres database to a service.

### Secrets

- `POSTGRES_PASSWORD`
- `POSTGRES_URL`

### Env Vars

- `POSTGRES_USER`
- `POSTGRES_DB`

### Security Group Rules

- `tcp:5432` <=> `postgres` connection
