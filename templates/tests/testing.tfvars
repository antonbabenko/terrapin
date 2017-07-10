image_id = "ami-6c101b0a" # ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server  in eu-west-1

instance_type = "t2.micro"
max_size = 1
min_size = 1
desired_capacity = 1

vpc_id = "vpc-9651acf1" # static one with cidr 172.31.0.0/16
subnet_ids = ["subnet-6fe3d837"] # static in eu-west-1c