# DEVOPS TOOLING WEBSITE SOLUTION

### STEP 1 – PREPARE NFS SERVER

1. Spin up a RHEL Linux EC2 Instance

2. Configure LVM on the Instance using "xfs" to format the disks instead of ext4.
<br>
N.B: There are 3 Logical Volumes. <b>lv-opt, lv-apps, and lv-logs</b>
</br>

3. Create mount points on /mnt directory for the logical volumes:

    *Mount lv-apps on /mnt/apps – for webservers <br>
    Mount lv-logs on /mnt/logs – for webserver logs <br>
    Mount lv-opt on /mnt/opt – for Jenkins*

4. Install NFS server and configure it to start on reboot
```
sudo yum -y update
sudo yum install nfs-utils -y
sudo systemctl start nfs-server.service
sudo systemctl enable nfs-server.service
sudo systemctl status nfs-server.service
```
5. Export the mounts for webservers subnet cidr to connect as clients. These webservers can be in the same subnet or in different subnets. For test purposes, we used same subnets but for production we would want to separate each tier inside its own subnet for higher level of security.
<br>
<br>
a. Set up permission that will allow our Web servers to read, write and execute files on NFS:
 ```
    sudo chown -R nobody: /mnt/apps
    sudo chown -R nobody: /mnt/logs
    sudo chown -R nobody: /mnt/opt

    sudo chmod -R 777 /mnt/apps
    sudo chmod -R 777 /mnt/logs
    sudo chmod -R 777 /mnt/opt

    sudo systemctl restart nfs-server.service
 ``` 
<br>
b. Configure access to NFS for clients within the same subnet (example of Subnet CIDR – 172.31.32.0/20 ):

```
    sudo vi /etc/exports
    /mnt/apps <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)
    /mnt/logs <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)
    /mnt/opt <Subnet-CIDR>(rw,sync,no_all_squash,no_root_squash)

    Esc + :wq!

    sudo exportfs -arv
```    
6. Check which port is used by NFS and open it using Security Groups (add new Inbound Rule) on the NFS server.
```
rpcinfo -p | grep nfs
```
N.B: <i>In order for NFS server to be accessible from your client, you must also open following ports: TCP 111, UDP 111, UDP 2049 <i/>