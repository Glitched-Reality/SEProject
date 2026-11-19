# Multi Project Manager

Project Documentation Goes Here for How to Use.

Things to make to get started

HTML files which PHP will change
PHP files to get data from database, make the HTML for client, handles sessions
SQL file to store all the database queries which the PHP can make, and make design of database
CPP files to handle daily and weekly tasks like generating reports

James handles some HTML, all SQL Queries, and the CPP files
Andy handles the PHP, using the SQL Queries, calling the CPP files, and editing the HTML to be usable
Dewey handles the documentation, HTML, and outward design of the website

## Test Environment
A database and web server is ready but needs content still. - Andy

## Laravel Commands

Install PHP 8.2 or newer and Composer, including Laravel's required PHP extensions and `pdo_mysql` when using MySQL. From the repository root on Linux or Ubuntu:

```sh
chmod +x app/install.sh
./app/install.sh install
./app/install.sh update
./app/install.sh start
./app/install.sh status
./app/install.sh stop
```

On Windows, use PowerShell:

```powershell
./app/install.ps1 install
./app/install.ps1 update
./app/install.ps1 start
./app/install.ps1 status
./app/install.ps1 stop
```

`install` runs Composer using the lock file when available, creates `app/.env` if missing, and generates an application key only when empty. `update` updates dependencies within the Composer version constraints. Configure database credentials in `app/.env`; do not commit it. The scripts also accept the previous `--update` (Linux) and `-Update` (PowerShell) options.

`start` launches PHP's development server in the background at http://127.0.0.1:8000. `status` and `stop` only manage the server started by the corresponding script. Output is written to `app/storage/logs`; check it if the server cannot start, including when port 8000 is already in use. This server is for local development, not production.