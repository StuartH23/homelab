provider "aws" {
  region = "us-east-2"
}

resource "aws_vpc" "app1-vpc" {
  cidr_block = "10.0.0.0/20" #required per the ticket to have /22 per subnet -SH
  tags = {
    Name = "app1-vpc"
  }
}



resource "aws_subnet" "app1-subnet-1" {
  vpc_id     = aws_vpc.app1-vpc.id
  cidr_block = cidrsubnet(aws_vpc.app1-vpc.cidr_block, 2, 0)
  # I tried to do 10.0.0.0/22 and 10.0.1.0/22 then 10.0.2.0/22 but i didn't understand
  # that I had to make it fall within 256 IPs perceptron, which in turn changed it, and
  # the real way to do this would be 10.0.0.0 , 10.0.4.0 , 10.0.8.0
  # which is why I used the cidrsubnet function to get the correct subnet so I can
  # document this for future reference -SH
  availability_zone = "us-east-2a"
  tags = {
    Name = "app1-subnet-1"
  }
}
resource "aws_subnet" "app1-subnet-2" {
  vpc_id            = aws_vpc.app1-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app1-vpc.cidr_block, 2, 1)
  availability_zone = "us-east-2b"
  tags = {
    Name = "app1-subnet-2"
  }
}

resource "aws_subnet" "app1-subnet-3" {
  vpc_id            = aws_vpc.app1-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.app1-vpc.cidr_block, 2, 2)
  availability_zone = "us-east-2c"
  tags = {
    Name = "app1-subnet-3"
  }
}

########################################################
# DynamoDB
########################################################
resource "aws_dynamodb_table" "app1-dynamodb" {
  name         = "app1-dynamodb"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "UserId"
  range_key = "TaskId"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "TaskId"
    type = "S"
  }

  tags = {
    Name = "app1-dynamodb"
  }
}
########################################################
# IAM
########################################################
resource "aws_iam_user" "devsuperuser" {
  name = "devsuperuser"
}
resource "aws_iam_user_policy_attachment" "devsuperuser-attach" {
  user       = aws_iam_user.devsuperuser.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


