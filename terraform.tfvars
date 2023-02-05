access = {
secret = ""
access = ""
}
alt = "10.0.0.0/16"
subnet = {
first_subnet = {
block = "10.0.1.0/24"
az = "us-east-1a"
}
second_subnet = {
block = "10.0.2.0/24"
az = "us-east-1b"
}
third_subnet = {
block = "10.0.3.0/24"
az = "us-east-1c"
}

}
loadbalancer = "web"
targetgroup = "site"
