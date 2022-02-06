# Automate Infrastructure With IaC using Terraform. Part 4 – Terraform Cloud

## What Terraform Cloud

**Terraform Cloud** is a managed service that provides you with Terraform CLI to provision infrastructure, either on demand or in response to various events.

**Managed** means that you do not have to install, configure and maintain it yourself – you just create an account and use it "as A Service".

**Terraform Cloud** executes Terraform commands on disposable virtual machines, this remote execution is also called [remote operations](https://www.terraform.io/docs/cloud/run/index.html).


## Setting Up Terraform Cloud

1. Create a Terraform Cloud account
Follow this [link](https://app.terraform.io/signup/account), create a new account, verify your email and you are ready to start

2. Create an organization

*Select "Start from scratch", choose a name for your organization and create it.*

3. Configure a workspace

When creating a workspace, you are provided with 3 options:
- version control workflow : You use a version control system to manage your Terraform configuration files. This will be triggered from your git repository.

- CLI-driven workflow : You use the Terraform CLI to manage your Terraform configuration files.

- API-driven workflow : You use the Terraform Cloud API to manage your Terraform configuration files.

It is recommended to use the version control workflow.


Create a new repository in your GitHub, push your Terraform codes to the repository. You can use this from my repo [here](https://github.com/Lordwales/PBL-terraform).

Choose version control workflow and you will be promped to connect your GitHub account to your workspace – follow the prompt and add your newly created repository to the workspace.

Move on to "Configure settings", provide a description for your workspace and leave all the rest settings default, click "Create workspace".


4. Configure variables
Terraform Cloud supports two types of variables: environment variables and Terraform variables. Either type can be marked as sensitive, which prevents them from being displayed in the Terraform Cloud web UI and makes them write-only.

Set two environment variables: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. These credentials will be used to privision your AWS infrastructure by Terraform Cloud. You can create this credentials by creating a new IAM user on AWS.

![alt](images/environmentVariable.png)

After you have set these 2 environment variables – yout Terraform Cloud is all set to apply the codes from GitHub and create all necessary AWS resources.

Also Terraform Cloud uses *auto.tfvars* file to store the variables. You can create this file bin your repo as you will see [her](https://github.com/Lordwales/PBL-terraform/blob/master/terraform.auto.tfvars). 

Incase you have some sensitive  variables you dont want to commit to the repo, you can add the variables in your local setup to the Terraform Cloud workspace.


**Note:**

[Packer](https://www.packer.io/) was used to create the ami images. It is a tool that can be used to create a Vagrant box. You can use this to create a virtual machine that can be used to provision your AWS infrastructure.

[Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) was used to configure the AWS infrastructure. It is a tool that can be used to provision your AWS infrastructure.

Check the AMI and Packer folders in the repo.


5. Run ```terraform plan ```and ```terraform apply``` from web console

Switch to "Runs" tab and click on "Queue plan manualy" button. If planning has been successfull, you can proceed and confirm Apply – press ***"Confirm and apply"***, provide a comment and ***"Confirm plan"***

![alt](images/cloudPlan.png)

![alt](images/destroy.png)

Terraform Cloud will create a terraform state file after the operations have completed.


6. Terraform cloud can also run our terraform code automatically in response to various events. For example, if there is any change in the files in our repo, this will trigger terraform cloud to iniitaite a new Terraform Plan and you can confirm and Apply afterwards.


## PRACTICE TASK 1

1. Configure 3 branches in your terraform-cloud repository for dev, test, prod environments

2. Make necessary configuration to trigger runs automatically only for dev environment

![alt](images/terraformDev.png)

3. Create an Email and Slack notifications for certain events (e.g. started plan or errored run) and test it

![alt](images/notification.png)

4. Apply destroy from Terraform Cloud web console



## Practice Task 2:  Working with Private repository

1. Create a simple Terraform repository (you can clone one from here) that will be your module

2. Import the module into your private registry

![alt](images/privateModule.png)

3. Create a configuration that uses the module

4. Create a workspace for the configuration

5. Deploy the infrastructure

6. Destroy your deployment


The tutorial [here](https://learn.hashicorp.com/tutorials/terraform/module-private-registry) will be of great help to achieve this.