resource "oci_core_vcn" "my_vcn" {
    count          = var.create_new_vcn ? 1 : 0
	compartment_id = var.compartment_ocid
	cidr_block     = var.network_cidr
	display_name   = var.network_name
	dns_label      = var.network_dns
}

resource "oci_core_internet_gateway" "my_internet_gateway" {
    count          = var.create_new_vcn ? 1 : 0
    compartment_id = var.compartment_ocid
	display_name   = "${var.network_name} Internet Gateway"
	enabled        = "true"
	vcn_id         = oci_core_vcn.my_vcn[0].id
}

resource "oci_core_nat_gateway" "my_nat_gateway" {
    count          = var.create_new_vcn ? 1 : 0
    compartment_id = var.compartment_ocid
	display_name   = "${var.network_name} NAT Gateway"
	vcn_id         = oci_core_vcn.my_vcn[0].id
}

resource "oci_core_service_gateway" "my_service_gateway" {
    count          = var.create_new_vcn ? 1 : 0
    compartment_id = var.compartment_ocid
	display_name   = "${var.network_name} Service Gateway"
	vcn_id         = oci_core_vcn.my_vcn[0].id

	services {
		service_id = data.oci_core_services.oci_network_services.services.0.id
	}
}

resource "oci_core_route_table" "route_table_private" {
    count          = var.create_new_vcn ? 1 : 0
    compartment_id = var.compartment_ocid
	display_name   = "${var.network_name} Private Route Table"
	vcn_id         = oci_core_vcn.my_vcn[0].id

	route_rules {
		description       = "Traffic to Internet"
		destination       = "0.0.0.0/0"
		destination_type  = "CIDR_BLOCK"
		network_entity_id = oci_core_nat_gateway.my_nat_gateway[0].id
	}

	route_rules {
		description       = "Traffic to OCI Services"
		destination       = data.oci_core_services.oci_network_services.services.0.cidr_block
		destination_type  = "SERVICE_CIDR_BLOCK"
		network_entity_id = oci_core_service_gateway.my_service_gateway[0].id
	}
}

resource "oci_core_default_route_table" "route_table_public" {
    count                      = var.create_new_vcn ? 1 : 0
    manage_default_resource_id = oci_core_vcn.my_vcn[0].default_route_table_id
	compartment_id             = var.compartment_ocid
	display_name               = "${var.network_name} Public Route Table"

	route_rules {
		destination       = "0.0.0.0/0"
		destination_type  = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.my_internet_gateway[0].id
	}
}

resource "oci_core_security_list" "security_list_private" {
    count          = var.create_new_vcn ? 1 : 0
	compartment_id = var.compartment_ocid
	display_name   = "${var.network_name} Private Security List"
	vcn_id         = oci_core_vcn.my_vcn[0].id

	egress_security_rules {
		destination      = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol         = "all"
		stateless        = "false"
	}
}

resource "oci_core_default_security_list" "security_list_public" {
    count                      = var.create_new_vcn ? 1 : 0
	manage_default_resource_id = oci_core_vcn.my_vcn[0].default_security_list_id
	compartment_id             = var.compartment_ocid
	display_name               = "${var.network_name} Public Security List"

	egress_security_rules {
		destination      = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		protocol         = "all"
		stateless        = "false"
	}

	ingress_security_rules {
		protocol    = "6"
		source      = "0.0.0.0/0"
		source_type = "CIDR_BLOCK"
		stateless   = "false"
		tcp_options {
			max = "22"
			min = "22"
		}
	}
}

resource "oci_core_subnet" "my_public_subnet" {
    count               = var.create_new_vcn ? 1 : 0
	cidr_block          = cidrsubnet(var.network_cidr, 8, 0)
	display_name        = "${var.network_name} Public Subnet"
	dns_label           = "public"
	security_list_ids   = [oci_core_vcn.my_vcn[0].default_security_list_id]
	compartment_id      = var.compartment_ocid
	vcn_id              = oci_core_vcn.my_vcn[0].id
	route_table_id      = oci_core_vcn.my_vcn[0].default_route_table_id
}

resource "oci_core_subnet" "my_private_subnet" {
    count                      = var.create_new_vcn ? 1 : 0
	cidr_block                 = cidrsubnet(var.network_cidr, 8, 1)
	display_name               = "${var.network_name} Private Subnet"
	dns_label                  = "private"
	prohibit_public_ip_on_vnic = "true"
	security_list_ids          = [oci_core_security_list.security_list_private[0].id]
	compartment_id             = var.compartment_ocid
	vcn_id                     = oci_core_vcn.my_vcn[0].id
	route_table_id             = oci_core_route_table.route_table_private[0].id
}
