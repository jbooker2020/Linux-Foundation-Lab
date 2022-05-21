# This Creates the VPC network for the Elastic Kibana server that uses the network 10.10.0.0/24
resource "aws_vpc" "try-vpc" {
  cidr_block = "10.10.0.0/24"

  tags = {
      Name = "try vpc"
  }
}

# This creates the internet gateway to send traffic to the internet
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.try-vpc.id

    tags = {
        Name = "try-aws_internet_gateway"
    }
}

# This creates a route table to determine where network traffic is directed
resource "aws_route_table" "try-route-table"{
    vpc_id = aws_vpc.try-vpc.id 

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
       ipv6_cidr_block        = "::/0"
       gateway_id = aws_internet_gateway.gw.id

    }

    tags = {
        Name = "try-route-table"
    }
}

# This creates the subnet for the Elastic Kibana server
resource "aws_subnet" "try-subnet" {
  vpc_id = aws_vpc.try-vpc.id
  cidr_block = "10.10.0.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "try-subnet"
  }
}

# This creates the route table association that bridges the gap between the subnet and the route table
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.try-subnet.id 
    route_table_id = aws_route_table.try-route-table.id 
}


/* This Creates Security Group that allows incoming traffic to go through
port 22 and any outgoing traffic
*/
resource "aws_security_group" "try-elk" {
  name = "try-elk"
  description = "allow all elasticsearch traffic"
  vpc_id = aws_vpc.try-vpc.id

  

  

  ingress {
      from_port = 22
      to_port = 22 
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
  }

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

}


 # This creates the network interface with the information of the subnet, private ips, and security groups
resource "aws_network_interface" "try-network-interface" {
    subnet_id       = aws_subnet.try-subnet.id
    private_ips = ["10.10.0.4"]
    security_groups = [aws_security_group.try-elk.id]
}

# This Creats Elastic IPs so there can be routable IP addresses on the internet
resource "aws_eip" "two" {
   vpc                       = true
  network_interface         = aws_network_interface.try-network-interface.id 
  associate_with_private_ip = "10.10.0.4"
  depends_on                = [aws_internet_gateway.gw] 
    
  
}

/*This creates the Ec2 instance specifying the type of Ec2 server(ami), the hardware the Ec2 server will
use (instance type), where the Ec2 server will be located (availability zone), and the key_name that is necessary to SSH into the Ec2 server
*/
resource "aws_instance" "Elk-stack-instance" {
  ami = "ami-0e472ba40eb589f49"
  instance_type = "m4.large"
  availability_zone = "us-east-1a"
  key_name = "main-key"
  
# This creates the network interface
  network_interface {
     device_index = 0
     network_interface_id = aws_network_interface.try-network-interface.id
  }
}