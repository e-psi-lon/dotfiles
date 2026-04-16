export PGDATA="/var/lib/postgresql/data"

shopt -s nullglob dotglob
files=("$PGDATA"/*)

# If PGDATA is an empty directory we initialize the db with initdb
if [ -d "$PGDATA" ] && [ ${#files[@]} -eq 0 ]; then
    echo "Initializing PostgreSQL database..."
    if [ -e "/run/secrets/postgres-password" ]; then
        echo "Using password from /run/secrets/postgres-password"
    else
        echo "No secret file found at /run/secrets/postgres-password. Please provide this file through a podman secret"
        exit 1
    fi
    initdb -D "$PGDATA" --auth=scram-sha-256 --pwfile=/run/secrets/postgres-password

    echo "host all all all scram-sha-256" >> "$PGDATA/pg_hba.conf"
else
    echo "PostgreSQL database already initialized."
fi

# Finally start the PostgreSQL server
echo "Starting PostgreSQL server..."
exec postgres -D "$PGDATA" -c listen_addresses='*'