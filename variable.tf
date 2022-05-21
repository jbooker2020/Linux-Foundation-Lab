
variable "AWS_ACCESS_KEY" {
    type = string
    default = "" # Enter access key between quotes
}
# T
variable "AWS_SECRET_KEY" {
    type = string
    default = "" # Enter secret key between quotes
} 

# This is the region the Ec2 instance will be deployed
variable "AWS_REGION" {
    default = "us-east-1" 
}