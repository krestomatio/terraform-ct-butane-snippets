terraform {
  required_version = ">= 1.2.0"

  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.11.0"
    }
  }
}
