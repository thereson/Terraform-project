variable "alt" {
type = string
}

variable "subnet" {
type = map(object({
block = string
az = string
}))
}
variable "loadbalancer" {
type = string
}
variable "targetgroup" {
type = string
}
