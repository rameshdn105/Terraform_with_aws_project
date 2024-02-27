#Create VPC resource
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

#create subnets in two diff regions
#map_public_ip_on_launch - (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.
resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
}

# create an internet gateway and routes and attach it to vpc. Route table: how traffic has to flow in subnet.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt01" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rt02" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

#create security group and it has inbound and outbound rules
resource "aws_security_group" "websg" {
  name = "websg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.myvpc.id

#ingress: inbound, egress:outbound, follow documentation
  ingress {
    description  = "HTTP from VPC"
    from_port    = 80
    to_port      = 80
    protocol     = "tcp"
   cidr_blocks   = ["0.0.0.0/0"]
  }

  ingress {
    description  = "SSH"
    from_port    = 22
    to_port      = 80
    protocol     = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

#create s3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "mys31nt13ME1212024project"
}

#create instances inside our subnets
resource "aws_instance" "webserver1" {
  ami = "ami-0e670eb768a5fc3d4"
  instance_type = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.websg.id]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "webserver2" {
  ami = "ami-0e670eb768a5fc3d4"
  instance_type = "t2.micro"
  vpc_security_group_ids  = [aws_security_group.websg.id]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("userdata1.sh"))
}

#create load balancer
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups    = [aws_security_group.websg.id]
  subnets            = [aws_subnet.sub2.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "myTG"
  port = "80"
  protocol = "http"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

#target group ready but its empty but e have to define what sould target group should do
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id  = aws_instance.webserver1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id  = aws_instance.webserver2.id
  port = 80
}

#LB is nt attached to target group
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn =  aws_lb_target_group.tg.arn
    type             = "forward"    
  }
}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
