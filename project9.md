# INSTALL AND CONFIGURE JENKINS SERVER

### Step 1 – Install Jenkins server

1. Create an EC2 ubuntu instance

2. Install JDK
```
sudo apt update
sudo apt install default-jdk-headless
```
3. Install Jenkins
```
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt-get install jenkins
```
4. Check the status of Jenkins to make sure its running
```
sudo systemctl status jenkins
``` 

5. Open TCP port 80 for the Jenkins server security group.
6. Visit http://<Jenkins-Server-Public-IP-Address-or-Public-DNS-Name>:8080 to setup jenkins with the admin password and also install the suggested plugins. <br>
Run the command below to retrieve the admin password
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Step 2 – Configure Jenkins to retrieve source codes from GitHub using Webhooks
Webhooks will help us in automating the build of our projects based on some trigger. With this project the build is triggered when a new update is pushed to the master branch.

1. Enable webhooks in your GitHub repository settings
![](Images/webhook.PNG)


2. Go to Jenkins web console, click "New Item" and create a "Freestyle project". Give the project a name and click ok. 

3. Connect the project to your github repo by providing link to the repo and github credentials(if repo is provate. A public repo does not need credentials).
![](Images/configureBuild.PNG)


4. Under <b>Build Trigger </b> check <b> Github hook trigger for GITScm polling</b>

5. Configure "Post-build Actions" to archive all the files – files resulted from a build are called "artifacts".<br>

In the drop down list pick <b> Archive Artifacts</b> and in the input box for <b> files to archive</b>, input <b> ** </b>.

6. click on save and make changes to your repo and commit. You should get an automatic build of the repo.
![](Images/Build.PNG)


7. The resulting artifacts are stored in the Var directory and that can be seen by running the command below.
```
ls /var/lib/jenkins/jobs/tooling_github/builds/<build_number>/archive/
```
![](Images/BuildArtifacts.PNG)
![](Images/artifactsDirectory.PNG)



### Step 3 – Configure Jenkins to copy files to NFS server via SSH

1. Install "Publish Over SSH" plugin. This will allow us copy our files to the NFS server which is shared across all webserver.

2. Configure the job/project to copy artifacts over to NFS server.<br>

On main dashboard select "Manage Jenkins" and choose "Configure System" menu item.
<br>

Scroll down to Publish over SSH plugin configuration section and configure it to be able to connect to your NFS server:

- Provide a private key (content of .pem file that you use to connect to NFS server via SSH/Putty)
- Arbitrary name
- Hostname – can be private IP address of your NFS server
- Username – ec2-user (since NFS server is based on EC2 with RHEL 8)
- Remote directory – /mnt/apps since our Web Servers use it as a mointing point to retrieve files from the NFS server. <br />

Click the Test the connection button. If everything is setup correctly,you should get a success message.
![](Images/TestConnection.PNG)


N.B: TCP port 22 on NFS server must be open to receive SSH connections.

3. Save the configuration

4. Open Jenkins job/project configuration page and add another one "Post-build Action"

5. Select <b> Send build over ssh </b> and enter <b> ** </b> in the text box infront of <b>Source files</b>
![](Images/sendSSH.PNG)


6. Save the configuration.

7. Make changes in repo and commit. Authomatic build should be triggered on jenkins and files sent to the NFS Server.
![](Images/sentSSH.PNG)


8. You can visit mnt/apps on NFS server to open the file you updated to see your new changes.