variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "key_name" {
  description = "SSH name "
  type        = string
  default     = "k8s-key"
}

variable "availability_zone" {
  description = "EC2 instance availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "sec_gr_mutual" {
  default = "phonebook_k8s_mutual_sec_group"
}

variable "sec_gr_k8s_master" {
  default = "phonebook_k8s_master_sec_group"
}

variable "sec_gr_k8s_worker" {
  default = "phonebook_k8s_worker_sec_group"
}



