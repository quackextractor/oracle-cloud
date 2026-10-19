resource "oci_core_vcn" "primary" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "primary-vcn"
  dns_label      = "main"
}

resource "oci_core_internet_gateway" "primary" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.primary.id
  display_name   = "primary-igw"
  enabled        = true
}

resource "oci_core_default_dhcp_options" "primary" {
  manage_default_resource_id = oci_core_vcn.primary.default_dhcp_options_id
  compartment_id             = var.compartment_ocid
  display_name               = "Default DHCP Options for primary-vcn"
  domain_name_type           = "CUSTOM_DOMAIN"
  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }
  options {
    type                = "SearchDomain"
    search_domain_names = ["main.oraclevcn.com"]
  }
}

resource "oci_core_default_route_table" "primary" {
  manage_default_resource_id = oci_core_vcn.primary.default_route_table_id
  compartment_id             = var.compartment_ocid
  display_name               = "Default Route Table for primary-vcn"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.primary.id
  }
}

resource "oci_core_default_security_list" "primary" {
  manage_default_resource_id = oci_core_vcn.primary.default_security_list_id
  compartment_id             = var.compartment_ocid
  display_name               = "Default Security List for primary-vcn"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    source   = var.ssh_allowed_cidr
    protocol = "6" # TCP
    tcp_options {
      min = 22
      max = 22
    }
  }
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "1" # ICMP path MTU discovery
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    source   = "10.0.0.0/16"
    protocol = "1"
    icmp_options {
      type = 3
      code = -1
    }
  }
}

resource "oci_core_subnet" "public" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.primary.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "public-subnet"
  dns_label                  = "pub"
  dhcp_options_id            = oci_core_default_dhcp_options.primary.id
  route_table_id             = oci_core_vcn.primary.default_route_table_id
  security_list_ids          = [oci_core_vcn.primary.default_security_list_id]
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}
