# AUTOMATE INFRASTRUCTURE WITH IAC USING TERRAFORM. PART 2

Read up on Networking:
- [Introduction to Networking](https://youtu.be/rL8RSFQG8do)
- [TCP/IP and Subnet Masking](https://youtu.be/EkNq4TrHP_U)
- [Networking Series](https://www.youtube.com/playlist?list=PLF360ED1082F6F2A5)


### Networking

#### Private subnets & best practices

Create 4 private subnets keeping in mind following principles:

- Make sure you use variables or length() function to determine the number of AZs
- Use variables and cidrsubnet() function to allocate vpc_cidr for subnets
- Keep variables and resources in separate files for better code structure and readability

main.tf private subnets code block:
```
# Create private subnets
resource "aws_subnet" "private" {
  count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets 
  vpc_id                     = aws_vpc.main.id
  cidr_block                 = cidrsubnet(var.vpc_cidr, 4 , count.index)
  map_public_ip_on_launch    = true
  availability_zone          = data.aws_availability_zones.available.names[count.index]

}
```
variables.tf private subnets variable:
```
variable "preferred_number_of_private_subnets" {
  default = null
}
```
terraform.tfvars private subnets variable: ```preferred_number_of_private_subnets = 4```

- Tag all the resources you have created so far. Explore how to use format() and count functions to automatically tag subnets with its respective number.

**TAGS**

- In terraform.tfvars file, add the following:

```
enviroment_name = "production"

owner_email = "fredyspinks@gmail.com"

managed_by = "Terraform"

billing_account = "0123456789"

tags = {
  Enviroment = var.enviroment_name
  Owner-Email = var.owner_email
  Managed-By = var.managed_by
  Billing-Account = var.billing_account
}

```
- In variables.tf file, add the following:
```
variable "tags" {
  description = "A mapping of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
```
- Now we can tag our resources with the tags we have defined in the variables.tf file like this:
```
tags = merge(
    var.tags,
    {
      Name = "Name of the resource"
    },
  )
```
***E.G***
private subnet section:

```
# Create private subnets
resource "aws_subnet" "private" {
  count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets 
  vpc_id                     = aws_vpc.main.id
  cidr_block                 = cidrsubnet(var.vpc_cidr, 4 , count.index)
  map_public_ip_on_launch    = true
  availability_zone          = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    {
      Name = "private subnet of the resources"
    },
  )

}
```
Benefits of tagging with this approach: we only need to change the tags in one place (terraform.tfvars) and we can easily see what resources are tagged with what tags.


### Internet Gateways & format() function

Create an Internet Gateway in a separate Terraform file ```internet_gateway.tf```

```
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-%s!", aws_vpc.main.id,"IG")
    } 
  )
}

```

We used format to dynamically generate the name of the resource by using ***format()*** function.

***The first part of the ```%s``` takes the interpolated value of aws_vpc.main.id while the second ```%s ```appends a literal string IG and finally an exclamation mark is added in the end.***

With this format function we can edit our private subnet section to look like this;

```
# Create private subnets
resource "aws_subnet" "private" {
  count = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets 
  vpc_id                     = aws_vpc.main.id
  cidr_block                 = cidrsubnet(var.vpc_cidr, 4 , count.index)
  map_public_ip_on_launch    = true
  availability_zone          = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.tags,
    {
      Name = format("PrivateSubnet-%s", count.index)
    },
  )

}
```

Now the name of our private subnets would be:
```

PrvateSubnet-0

PrvateSubnet-1

PrvateSubnet-2

PrvateSubnet-3
```

### NAT Gateways
#### Create 1 NAT Gateways and 1 Elastic IP (EIP) addresses
- create a new file called ```natgateway.tf```.