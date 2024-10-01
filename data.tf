data "oci_core_services" "oci_network_services" {
	filter {
		name   = "name"
		values = ["All .* Services In Oracle Services Network"]
		regex  = true
	}
}

data "oci_identity_availability_domains" "region_availability_domains" {
	compartment_id = var.compartment_ocid
}

data "oci_container_instances_container_instance_shape" "container_instance_shape" {
    compartment_id      = var.compartment_ocid
    availability_domain = data.oci_identity_availability_domains.region_availability_domains.availability_domains.0.name
}

data "oci_core_images" "shape_specific_images" {
	compartment_id           = var.compartment_ocid
	shape                    = var.compute_shape
	operating_system         = var.compute_os
	sort_by                  = "TIMECREATED"
	sort_order               = "DESC"
}

locals {
  first_image_id = length(data.oci_core_images.shape_specific_images.images) > 0 ? data.oci_core_images.shape_specific_images.images[0].id : null
}
