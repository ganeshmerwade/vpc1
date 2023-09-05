resource "tls_private_key" "devopsninja_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "pem_key" {
  content  = tls_private_key.devopsninja_private_key.private_key_pem
  filename = var.key_pair_path
  file_permission = "0400"
}

resource "aws_key_pair" "devopsninja_key_pair" {
  key_name = var.key_pair_key_name
  public_key = tls_private_key.devopsninja_private_key.public_key_openssh 
}