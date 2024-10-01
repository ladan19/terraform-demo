
variable "compartment_ocid" {
  default = ""
  description  = "Entre com o OCID do compartimento"
}
variable "create_new_vcn" {
    default = ""
    description  = "0 não cria e o 1 cria"
}
variable "subnet_id" {
    default = ""
    description = "O ID da subnet para o deploy da instancia"
}
variable "network_cidr" {
    default = ""
}
variable "network_name" {
    default = "terraform-vcn"
}
variable "network_dns" {
    default = "teste"
}
variable "instance_name" {
    default = "teste-tf"
}
variable "compute_model" {
    default = "AMD"
    description = "AMD, AMPERE ou INTEL"
}
variable "compute_shape" {
    default = "VM.Standard.E4.Flex"
    description = "VM.Standard.E4.Flex se for AMD ou VM.Standard.A1.Flex se for AMPERE"
}
variable "compute_ocpu" {
    default = "1"
    description= "Entre com o valor de OCPU"
}
variable "compute_memory" {
    default = "2"
    description= "Entre com o valor de Memoria"
}
variable "compute_disk" {
    default = "50"
    description = "Quantidade de Storage"
}
variable "compute_vpu" {
    default = "10"
    description = "Valor de VPU"
}
variable "compute_os" {
    default = "Canonical Ubuntu"
    description = "Oracle Linux, Canonical Ubuntu, CentOSv, AlmaLinux ou Rocky Linux"  
}

variable "compute_ssh_key" {
    default = ""
    description = "Chave publica para sua instancia"
}
