variable "project" {
  description = "The project ID to host the cluster in"
  type        = string
  default     = "polar-cyclist-244407"
}

variable "location" {
  description = "The location (region or zone) to host the cluster in"
  type        = string
  default     = "us-central1-a"
}

variable "name" {
  description = "The name of the cluster"
  type        = string
  name        = "hamoudi_terraform1"
}

variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
  name        = "default"
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
  name        = "default"
}
