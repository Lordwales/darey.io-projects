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