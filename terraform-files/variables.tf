# All values come from terraform.tfvars (gitignored). See terraform.tfvars.example.

variable "tenancy_ocid" { sensitive = true }
variable "user_ocid" { sensitive = true }
variable "fingerprint" { sensitive = true }
variable "private_key_path" { default = "oci_api_key.pem" }
variable "region" { default = "eu-zurich-1" }
variable "availability_domain" { default = "aEKz:EU-ZURICH-1-AD-1" }

# Always Free resources must be created in the root compartment of the home region.
variable "compartment_ocid" { sensitive = true }

variable "ssh_public_key" { sensitive = true }
variable "ssh_allowed_cidr" {
  description = "Your public IP in CIDR form; only this address may SSH in."
  sensitive   = true
}

variable "image_ocid" {
  default = "ocid1.image.oc1.eu-zurich-1.aaaaaaaagt4fin33bgwrmpianub6pdwog5g27fxyg3vwwwztwidvc2g4knqa"
}
