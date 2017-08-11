# Database

Stepup should work work both Mysql and MariaDB (version 10.0), it has been especially developed with a MariaDB Galera cluster in mind however. Stepup-Deploy can work with an existing Galera cluster, or you can use Stepup-Deploy to setup a new one, including a "one node cluster" for testing/development purposes. To allow this the database and database user creation is handles by two different roles:
* The `db` role installs a MariaDB Galera cluster
* The `dbconfig` role creates database users, sets their permissions and creates database schemas. Creation of tables, indexes etc in the databases is handled by the applications and is not handled using Ansible.

## Using an existing cluster

To use an existing database cluster:
* do _not_ put any hosts in the `dbcluster` group in the inventory. The `db` role is deployed to hosts in this group, which sets-up a MariaDB Galera cluster node on the host.
* set the `database_stepup_deploy_password` and `database_stepup_deploy_user` in `group_vars/dbconfig.yml` to an existing user on the cluster that is allowed to create users and database schema's (i.e. a "root" user). Note that the `database_stepup_deploy_password` is encrypted. Use `encrypt.sh` to encrypt the password. To create an additional root user:
```sql
CREATE USER 'stepup_deploy'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'stepup_deploy'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```
* set the `database_lb_address` in `group_vars/all.yml` to the IP address of the database. The `dbconfig` role is executed from the host in the stepup-middleware group, so make sure that the host(s) in this group can login to database_lb_address as the stepup_deploy_user user.

## Setting up a new cluster

To create a database cluster put the hosts that make up the cluster in the `dbcluster` group, this includes the `db` role. Note that, as configured by the `db` role, none of the communication between the cluster nodes themselves, between the cluster nodes and the stepup components is encrypted. The databases cluster can consist of only one node, which is useful for testing purposes.

The template environment is already set up to use the cluster created by the db role.

### Galera

Much can be said about running a Galera cluster. Before setting up one and running one in a production setting you should familiarise yourfelf with this technology. More information on Galera can be found on: http://galeracluster.com/
Note that Galera is not a requirement for Stepup. It will work fine with a normal Mysql/MariaDB database.

### Galera cluster bootstrap

The template inventory consists of one database node running on the application server. In production setting you would setup a Galera cluster running on an uneven number > 1 of dedicated machines. In a Galera cluster, when none of the MariaDB databases is running, such as during the first deploy, the first database must be bootstrapped. The `db` can take care of that but you must explicitly designate the node to bootstrap by setting the Ansible variable `galera_bootstrap_node` to the hostname of the node to bootstrap. Example:
 ```bash
 ansible-playbook site.yml -i <environment_directory>/inventory -e "galera_bootstrap_node=app.stepup.example.com"
 ```

The need to "bootstrap" the first node in a Galera cluster is a notable difference between a normal mysql/mariaDB database and a Galera cluster. When no nodes of the cluster are running you must start the first database with `service mysql bootstrap`. Any other nodes must be started with `service mysql start`.


## The dbconfig role

The `dbconfig` role creates the databases and and database users for the stepup components. A complete deployment uses five databases: middleware, gateway, u2f, tiqr and keyserver

Both the `middleware` and the `gateway` databases are required when using any of the "core" Stepup components (Stepup-Gateway, Stepup-Middleware, Stepup-SelfService and Stepup-RA) because these components al depend on each other.

The Tiqr GSSP requires the `tiqr` database. When using a separate keyserver for storing the OATH secrets for Tiqr, the `keyserver` database is required.

When U2F is enabled the `u2f` database is required.

The `database_stepup_deploy_user` is used to create all the other database schema's and database users. For the creation of the tables and indexes in the schema's scripts are installed in the `/root/` directory of the application server(s). These scripts need to be called separately, they are not executed from any Ansible role. The scripts are idempotent (i.e. it is safe to execute them multiple times). When a new version of an application requires a database schema update, this is indicated in the CHANGELOG. These same scripts are used to update the database schema from one release to another.
