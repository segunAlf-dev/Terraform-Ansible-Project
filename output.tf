output "Public1" {
 value = "aws_subnet.public1.id"
}

output "Public2" {
 value = "aws_subnet.public2.id"
}

output "Public3" {
 value = "aws_subnet.public3.id"
}

output "Public_ip1" {
 value = "aws_instance_server1.public_ip"
}

output "Public_ip2" {
 value = "aws_instance_server2.public_ip"
}

output "Public_ip3" {
 value = "aws_instance_server3.public_ip"
}

output "Application_LB_DNS" {
  value = aws_lb.Application_LB.dns_name
}

output "Target_group_DNS" {
  value = aws_lb_target_group.target_G.arn
}
