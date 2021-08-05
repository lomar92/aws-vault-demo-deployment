data "template_file" "user_data" {
  template = file("${path.module}/webapp.sh")
}

resource "aws_instance" "vault-client" {                    
  security_group              = aws_security_group.sg_vpc.id 
  instance_name               = "vault-client"
  ami                         = var.ami 
  instance_type               = var.instance_type
  key_name                    = var.key
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  iam_instance_profile        = aws_iam_instance_profile.vault-client.id

  tags = {
    Name = aws_instance.vault-client.instance_name
  }
}
