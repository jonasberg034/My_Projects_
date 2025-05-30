region            = "us-east-1"
instance_type     = "t3a.medium"
ami_id            = "ami-0f9de6e2d2f067fca"  # Ubuntu 22.04, SSD volume Type
key_name          = "jonaspem"
sec_gr_mutual     = "petclinic_k8s_mutual_sec_group"
sec_gr_k8s_master = "petclinic_k8s_master_sec_group"
sec_gr_k8s_worker = "petclinic_k8s_worker_sec_group"
subnet_id         = "subnet-0f2de93dd0ff5f4d3"  # select own subnet_id of us-east-1a