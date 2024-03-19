variable "name" {
  description = "Name to give to the vm, its port and the prefix of security groups"
  type        = string
  default     = ""
}

variable "image_source" {
  description = "Source of the vm's image"
  type = object({
    image_id  = string
    volume_id = string
  })
}

variable "flavor_id" {
  description = "ID of the VM flavor for the node"
  type        = string
}

variable "kubernetes_workers_security_group_id" {
  description = "Id of the security group for the kubernetes workers zeppelin will interact with"
  type        = string
}

variable "additional_security_group_ids" {
  description = "Additional security groups of the node"
  type        = list(string)
  default     = []
}

variable "fluentd_security_group" {
  description = "Fluentd security group configuration"
  type = object({
    id   = string
    port = number
  })
  default = {
    id   = ""
    port = 0
  }
}

variable "network_id" {
  description = "Id of the network the node will be attached to"
  type        = string
}

variable "keypair_name" {
  description = "Name of the keypair that will be used to ssh to the node"
  type        = string
}

variable "client_group_ids" {
  description = "Id of client security groups"
  type        = list(string)
  default     = []
}

variable "bastion_group_ids" {
  description = "Id of bastion security groups"
  type        = list(string)
  default     = []
}

variable "metrics_server_group_ids" {
  description = "Id of metric servers security groups"
  type        = list(string)
  default     = []
}

variable "nameserver_ips" {
  description = "Ips of the nameservers"
  type        = list(string)
  default     = []
}

variable "zeppelin_version" {
  description = "Version of zeppelin"
  type        = string
  default     = "0.11.0"
}

variable "zeppelin_mirror" {
  description = "Mirror from which to download zeppelin"
  type        = string
  default     = "https://mirror.csclub.uwaterloo.ca/apache"
}

variable "k8_executor_image" {
  description = "Image to launch k8 executor from"
  type        = string
  default     = "apache/spark:3.5.1"
}

variable "k8_service_account_name" {
  description = "Service account name to use"
  type        = string
}

variable "k8_namespace" {
  description = "Namespace to use"
  type        = string
}

variable "k8_api_endpoint" {
  description = "Endpoint to access the k8 masters"
  type        = string
}

variable "k8_ca_certificate" {
  description = "CA certicate of kubernetes api"
  type        = string
}

variable "k8_client_certificate" {
  description = "Client certicate to access kubernetes api"
  type        = string
}

variable "k8_secret_s3" {
  description = "Name of kubernetes secret to use for S3 credentials for executors pods"
  type        = string
}

variable "k8_secret_s3_access_key" {
  description = "Key in k8_secret_s3 secret which contains the S3 access key"
  type        = string
}

variable "k8_secret_s3_secret_key" {
  description = "Key in k8_secret_s3 secret which contains the S3 secret key"
  type        = string
}

variable "k8_client_private_key" {
  description = "Client private key to access kubernetes api"
  type        = string
}


variable "s3_access" {
  description = "S3 access key"
  type        = string
}

variable "s3_secret" {
  description = "S3 secret key"
  type        = string
}

variable "s3_url" {
  description = "url of the S3 store"
  type        = string
}

variable "hive_metastore_port" {
  description = "Port of the hive metastore on the kubernetes cluster"
  type        = number
}

variable "hive_metastore_url" {
  description = "Url of the hive metastore"
  type        = string
}

variable "spark_sql_warehouse_dir" {
  description = "S3 path of the spark sql warehouse"
  type        = string
}

variable "spark_max_executors" {
  description = "Number maximum of spark executors"
  type        = number
  default     = 15
}

variable "spark_min_executors" {
  description = "Number minimum of spark executors"
  type        = number
  default     = 0
}

variable "spark_dynamic_allocation_enabled" {
  description = "Enable dynamic allocation of spark executors"
  type        = bool
  default     = true
}

variable "notebook_s3_bucket" {
  description = "S3 bucket to store notebooks under"
  type        = string
}

variable "keycloak" {
  description = "Keycloak configuration for user authentication"
  type = object({
    enabled       = bool
    url           = string
    realm         = string
    client_id     = string
    client_secret = string
    zeppelin_url  = string
  })
  default = {
    enabled       = false
    url           = ""
    realm         = ""
    client_id     = ""
    client_secret = ""
    zeppelin_url  = ""
  }
}

variable "fluentbit" {
  description = "Fluent-bit configuration"
  type = object({
    enabled           = bool
    zeppelin_tag      = string
    node_exporter_tag = string
    metrics = object({
      enabled = bool
      port    = number
    })
    forward = object({
      domain     = string
      port       = number
      hostname   = string
      shared_key = string
      ca_cert    = string
    })
  })
  default = {
    enabled           = false
    zeppelin_tag      = ""
    node_exporter_tag = ""
    metrics = {
      enabled = false
      port    = 0
    }
    forward = {
      domain     = ""
      port       = 0
      hostname   = ""
      shared_key = ""
      ca_cert    = ""
    }
  }
}
