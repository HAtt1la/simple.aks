resource "azurerm_resource_group" "simple-aks" {
  name     = "simple-aks"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "simple-aks" {
  name                  = "simple-aks"
  location              = azurerm_resource_group.simple-aks.location
  resource_group_name   = azurerm_resource_group.simple-aks.name
  dns_prefix            = "simple-aks"            
  kubernetes_version    =  var.kubernetes_version
  
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_b2s"
    type       = "VirtualMachineScaleSets"
    os_disk_size_gb = 50
  }

  service_principal  {
    client_id = var.serviceprinciple_id
    client_secret = var.serviceprinciple_key
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
        key_data = var.ssh_key
    }
  }

  network_profile {
      network_plugin = "kubenet"
      load_balancer_sku = "standard"
  }
}