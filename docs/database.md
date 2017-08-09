Stepup-Deploy can work with an existing MariaDB cluster you can setup it's own. To use an existing cluster:
* do not use the `dbcluster` group. This group includes the `db` role.
* set the `database_stepup_deploy_password` and `database_stepup_deploy_user` in `group_vars/dbconfig.yml` to an existing user on the cluster that is allowed to create users and database schema's (i.e. a "root" user).
* set the `database_lb_address` in `group_vars/all.yml` to the IP address of the database.

To create a database cluster put the hosts that make up the cluster in the `dbcluster` group, this includes the `db` role. Note that none of the communication between the cluster nodes themselves, between the cluster nodes and the stepup components is encrypted. The databases cluster can consist of only one node, which is useful for testing purposes.

The `dbconfig` role creates the databases and and database users for the stepup components. A complete deployment uses five databases: middleware, gateway, u2f, tiqr and keyserver

Both the `middleware` and the `gateway` databases are required when using any of the "core" Stepup components (Stepup-Gateway, Stepup-Middleware, Stepup-SelfService and Stepup-RA) because these components al depend on each other.

The Tiqr GSSP requires the `tiqr` database. When using a separate keyserver for storing the OATH secrets for Tiqr, the `keyserver` database is required.

When U2F is enabled the `u2f` database is required.

The `database_stepup_deploy_user` is used to create all the other database schema's and database users. For the creation of the tables and indexes in the schema's scripts are installed in the `/root/` directory of the application server(s). These scripts need to be called separately, they are not executed from any Ansible role. The scripts are idempotent (i.e. it is safe to execute them multiple times). When a new version of an application requires a database schema update, this is indicated in the CHANGELOG. These same scripts are used to update the database schema from one release to another.
