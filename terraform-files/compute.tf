# Always Free Ampere A1: max 4 OCPU / 24 GB RAM / 200 GB storage total per tenancy.
resource "oci_core_instance" "industrialist" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  display_name        = "industrialist-qa-srv"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
    boot_volume_size_in_gbs = 200
    boot_volume_vpus_per_gb = 10
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.public.id
    display_name              = "industrialist-primary-vnic"
    assign_public_ip          = true
    assign_ipv6ip             = false
    assign_private_dns_record = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  is_pv_encryption_in_transit_enabled = true

  availability_config {
    recovery_action = "RESTORE_INSTANCE"
  }

  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      name          = "Vulnerability Scanning"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Management Agent"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Custom Logs Monitoring"
      desired_state = "ENABLED"
    }
    plugins_config {
      name          = "Compute RDMA GPU Monitoring"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = "ENABLED"
    }
    plugins_config {
      name          = "Compute HPC RDMA Auto-Configuration"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Compute HPC RDMA Authentication"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Cloud Guard Workload Protection"
      desired_state = "ENABLED"
    }
    plugins_config {
      name          = "Block Volume Management"
      desired_state = "DISABLED"
    }
    plugins_config {
      name          = "Bastion"
      desired_state = "DISABLED"
    }
  }
}

output "private_ip" { value = oci_core_instance.industrialist.private_ip }
output "public_ip" { value = oci_core_instance.industrialist.public_ip }
