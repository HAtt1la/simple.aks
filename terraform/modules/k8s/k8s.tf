provider "kubernetes" {
    host                   =  var.host
    client_certificate     =  var.client_certificate
    client_key             =  var.client_key
    cluster_ca_certificate =  var.cluster_ca_certificate

}


resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      test = "nginxExampleApp"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "nginxExampleApp"
      }
    }
  

    template {
      metadata {
        labels = {
          test = "nginxExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.18.0"
          name  = "nginx"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      test = "nginxExampleApp"
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}