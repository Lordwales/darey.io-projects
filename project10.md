# LOAD BALANCER SOLUTION WITH NGINX AND SSL/TLS

### Part 1 – Configure Nginx As A Load Balancer
1. Using the existing Ubuntu server from project 3 that has Nginx already installed in it. TCP port 80 has also been opened and addition HTTPS port 443 has been opened.

2. Update /etc/hosts file for local DNS with Web Servers names (e.g. Web1 and Web2) and their local IP addresses just like it was done with the apache load balancer.

3. configure Nginx as a load balancer to point traffic to the resolvable DNS names of the webservers
```
sudo vi /etc/nginx/nginx.conf

#insert following configuration into http section

 upstream myproject {
    server Web1 weight=5;
    server Web2 weight=5;
  }

server {
    listen 80;
    server_name www.domain.com;
    location / {
      proxy_pass http://myproject;
    }
  }

#comment out this line
#       include /etc/nginx/sites-enabled/*;
```
4. Restart Nginx.
```
sudo systemctl restart nginx
sudo systemctl status nginx
```
