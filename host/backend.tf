terraform {
    backend "gcs" {
        bucket  = "py-host-01-tfstate"
        prefix  = "terraform/state"
    }
}