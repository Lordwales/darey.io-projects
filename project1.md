# Web stack implementation (lamp stack) in aws

This shows a simple implementation of a web stack in aws.<br>
Note: The EC2 instance is not created here. It has been created already

### STEP 1 — INSTALLING APACHE AND UPDATING THE FIREWALL

1. Install Apache using the following commands:
```
#update a list of packages in package manager
 sudo apt update

#run apache2 package installation
 sudo apt install apache2
```
picture

2. Verify your installation by running the following command:
```
 sudo service apache2 status
```
3. Add a new inbound rule to the EC2 Instance's firewall; this will allow the
 EC2 Instance to receive HTTP requests from the Internet.

4. Access you new apache web server using the following URL:
```
 http://<ec2-instance-public-ip-address>
```
NOTE: The EC2 Instance's public IP address can be found by running the following command:
```
 curl -s http://169.254.169.254/latest/meta-data/public-ipv4
```

### STEP 2 — INSTALLING MYSQL AND UPDATING THE FIREWALL

1. Install MySQL using the following commands:
```
sudo apt install mysql-server
```
2. You need to run security script 
that comes pre-installed with MySQL. This script will remove some insecure default settings and lock down access to your database system. Start the interactive script by running:
```
sudo mysql_secure_installation
```
This will ask you to configure the validation plugin which helps with passsword strength check. If one wants it enabaled; answer Y to the prompt If not, press any other key.

<b> NOTE: Always use a strog password for MySQL. </b>

3. Test your MySQL installation by running the following command:
```
sudo mysql
```
If installation is successful, you should see the following message:
image

<b>Note: At the time of this writing, the native MySQL PHP library mysqlnd doesn’t support caching_sha2_authentication, the default authentication method for MySQL 8. For that reason, when creating database users for PHP applications on MySQL 8, you’ll need to make sure they’re configured to use mysql_native_password instead.</b>
