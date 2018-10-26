#!/bin/bash
set -e

psql --username "$POSTGRES_USER" -c "CREATE DATABASE tasks_service"
psql --username "$POSTGRES_USER" -c "GRANT ALL PRIVILEGES ON DATABASE tasks_service TO $POSTGRES_USER"
psql --username "$POSTGRES_USER" tasks_service < /tasks.sql

