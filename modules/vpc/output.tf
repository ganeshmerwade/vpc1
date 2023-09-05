output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "application_subnet_ids" {
  value = "${aws_subnet.private_application_subnet.*.id}"
}

output "database_subnet_ids" {
  value = "${aws_subnet.private_database_subnet.*.id}"
}

output "middleware_subnet_ids" {
  value = "${aws_subnet.private_middleware_subnet.*.id}"
}

