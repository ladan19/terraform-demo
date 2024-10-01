resource "oci_core_instance" "oci_compute" {
	availability_domain = data.oci_identity_availability_domains.region_availability_domains.availability_domains.0.name
	compartment_id      = var.compartment_ocid
	display_name        = var.instance_name

	shape               = var.compute_shape
	shape_config {
		memory_in_gbs = var.compute_memory
		ocpus         = var.compute_ocpu
	}
	availability_config {
		is_live_migration_preferred = "true"
		recovery_action = "RESTORE_INSTANCE"
	}
	create_vnic_details {
		assign_ipv6ip             = "false"
		assign_private_dns_record = "true"
		assign_public_ip          = "true"
		subnet_id                 = var.create_new_vcn ? oci_core_subnet.my_public_subnet[0].id : var.subnet_id
	}
	instance_options {
		are_legacy_imds_endpoints_disabled = "false"
	}
	metadata = {
		"ssh_authorized_keys" = var.compute_ssh_key
	}
	source_details {
		boot_volume_size_in_gbs = var.compute_disk
		boot_volume_vpus_per_gb = var.compute_vpu
		source_id               = local.first_image_id
		source_type             = "image"
	}
	is_pv_encryption_in_transit_enabled = "true"
}
