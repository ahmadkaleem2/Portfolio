#!/bin/bash
echo "asdasdasd" > /tmp/logs.txt
sudo apt install mysql-server -y >> /tmp/logs.txt
echo "sql-server install complete" >> /tmp/logs.txt
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf >> /tmp/logs.txt
sudo mysql -u root -e "SHOW DATABASES;CREATE DATABASE IF NOT EXISTS ${DB_NAME};CREATE USER '${DB_USERNAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';GRANT ALL PRIVILEGES ON *.* TO '${DB_NAME}'@'%' WITH GRANT OPTION;FLUSH PRIVILEGES;SHOW DATABASES;" >> /tmp/logs.txt
sudo systemctl restart mysql >> /tmp/logs.txt