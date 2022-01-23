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

***Note:*** We need to create an Elastic IP for the NAT Gateway, and you can see the use of ```depends_on``` to indicate that the Internet Gateway resource must be available before this should be created. Although Terraform does a good job to manage dependencies, but in some cases, it is good to be explicit

```
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]

  tags = merge(
    var.tags,
    {
      Name = format("%s-EIP", var.name)
    },
  )
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]

  tags = merge(
    var.tags,
    {
      Name = format("%s-Nat", var.name)
    },
  )
}
```

We used the ***element()*** function to select the first element of the array of subnets.
``` element(list, index) ```

```element(aws_subnet.public.*.id, 0)``` Fetches the first element of the array of subnets.

### AWS ROUTES

Create a file called ```route_tables.tf``` and use it to create routes for both public and private subnets.

Now we Create a route table for the public subnets and a route table for the private subnets.

- aws_route_table
- aws_route
- aws_route_table_association

```
# create private route table
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-Private-Route-Table", var.name)
    },
  )
}

# associate all private subnets to the private route table
resource "aws_route_table_association" "private-subnets-assoc" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private-rtb.id
}

# create route table for the public subnets
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = format("%s-Public-Route-Table", var.name)
    },
  )
}

# create route for the public route table and attach the internet gateway
resource "aws_route" "public-rtb-route" {
  route_table_id         = aws_route_table.public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# associate all public subnets to the public route table
resource "aws_route_table_association" "public-subnets-assoc" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public-rtb.id
}

```

### AWS Identity and Access Management

#### IAM and Roles

We want to pass an IAM role our EC2 instances to give them access to some specific resources, so we need to do the following:

1. Create AssumeRole

Assume Role uses Security Token Service (STS) API that returns a set of temporary security credentials that you can use to access AWS resources that you might not normally have access to. These temporary credentials consist of an access key ID, a secret access key, and a security token. Typically, you use AssumeRole within your account or for cross-account access.

Add the following code to a new file named ```roles.tf```

```
resource "aws_iam_role" "ec2_instance_role" {
name = "ec2_instance_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "aws assume role"
    },
  )
}
```

we are creating AssumeRole with AssumeRole policy. It grants to an entity, in our case it is an EC2, permissions to assume the role.

2. Create IAM policy for this role
```
resource "aws_iam_policy" "policy" {
  name        = "ec2_instance_policy"
  description = "A test policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]

  })

  tags = merge(
    var.tags,
    {
      Name =  "aws assume policy"
    },
  )

}
```

3. Attach the Policy to the IAM Role

we will be attaching the policy which we created above, to the role we created in the first step.

```
resource "aws_iam_role_policy_attachment" "test-attach" {
    role       = aws_iam_role.ec2_instance_role.name
    policy_arn = aws_iam_policy.policy.arn
}
```

4. Create an Instance Profile and interpolate the IAM Role

```
resource "aws_iam_instance_profile" "ip" {
    name = "aws_instance_profile_test"
    role =  aws_iam_role.ec2_instance_role.name
}
```

