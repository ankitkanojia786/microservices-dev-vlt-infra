terraform {
  backend "s3" {
    # Backend configuration will be provided via backend config file or CLI
    # This allows for dynamic bucket and region selection based on environment
  }
}