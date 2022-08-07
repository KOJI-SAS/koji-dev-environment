# Koji environment

## Usage

You first need to copy all `secrets/*.dummy` files, remove the `.dummy` extension and set the values as you want.

Then copy the `.env.dist` to `.env` and edit the `*_PORT` values to anything you want.

Then simply run `./install.sh` and you are set. Docker will automatically pull the passwords from the files without storing them in your current environment, and will create the `*-data` folders or use those that exist.
Alternatively, you can run `docker-compose up -d` but the project's name will simply be the name of the folder you ran the command in.

## Why?

There is no common dev environment yet, and the devs at Koji that know how to manage volumes and secrets will be able to have a secure environment where deleting a container does not mean deleting your data.
The devs that don't will end up deleting all their database data when upgrading a container that was simply run from the command line.

This aims to solve this problem, and provide an easy way to have the tools we use at koji to be installed as containers with the database store on disk in case you need to re-create your container.

In case you don't want a specific container or want to remove it, just stop it from the `Docker Desktop` application and delete it, or use the command line. :)

## FAQ

### I have existing DBs, how can I keep my data?

If using PostgreSQL, and you should since we're mostly using that at Koji and Timescale is a layer on top of PostgreSQL, you can:

1. Launch a shell into the container you want to backup using the `Docker Desktop` application, or running the following command: `docker exec -it {container_id} /bin/sh`.
2. Dump all your databases data with `pg_dumpall -O -c -U {postgres_user} -f dump_$(date +%Y-%m-%d_%H_%M_%S).sql`:
    - `-O`: No owner. The user that will restore the databases will get ownership of all objects
    - `-c`: Include SQL commands to clean (drop) databases before recreating them. DROP commands for roles and tablespaces are added as well.
    - `-U`: Username to connect as. `{postgres_user}` should be postgres, or the user you set when creating the database.
    - `-f`: Send output to the specified file
3. Log out of the container and copy the dump file where you want: `docker cp {container_id}:{dump_file_path} {host_path}`.
4. Do the same and copy the dump file to the new container: `docker cp {host_path} {new_container_id}:/`.
5. Launch a shell into the new destination container using the `Docker Desktop` application, or running the following command: `docker exec -it {container_id} /bin/sh`.
6. Restore the data using `psql`: `psql -U {postgres_user} -f {dump_file}`