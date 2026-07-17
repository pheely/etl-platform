terraform {
    backend "gcs" {
        bucket  = "py-service-01-tfstate"
        prefix  = "terraform/state"
    }
}