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
  default     = "hamoudi_terraform1"
}

variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
  default     = "default"
}

variable "image" {
  description = "A referecnce to the image boot disk"
  type       = string
  default    = "debian-12-bookworm-v20240709"
}

variable "machine_type" { 
  description = "A reference to the machine type reosources"
  type        = string
  default     = "e2-micro"
}

