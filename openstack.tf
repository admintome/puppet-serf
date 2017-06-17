# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "admin"
  tenant_name = "demo"
  auth_url    = "http://{your openstack ip here}:5000/v3"
  domain_name = "Default"
}
