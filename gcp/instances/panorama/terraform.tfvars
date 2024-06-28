# General
project     = "trace-vpc-edge-prod-01"
region      = "us-east4"
name_prefix = "trace-"

# Panorama

panoramas = {
  "panorama-01" = {
    zone              = "us-east4-a"
    panorama_name     = "panorama-01"
    subnetwork_key    = "edge-netmgmt-subnet-01"
    panorama_version  = "panorama-byol-1000"
    ssh_keys          = "admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPpoO5sULIBnt+XvrsED9iYv6w2BNjf1b7b/2HjGPVUWpzCJIcQesndrnC1b4MuHHVVWHMYXjWqilSc11882nXNwcqIGsTDxQQA4RWVS6XNakYUndyk1QPeSQZr+a10gqxbrbniQ+yXX4V/lwjhwtmV/pgnZPMJP8AkhvfQhbAkNBBDt1mNdXrPujeuCQxqFlheGkTx/OaW587tF3dJ5/klyAOXB4aQahehtwvjWRQNOpGFQau0i5ZECFoIRKrPP9GKTntU9Ob7bLDksbgIkkAC6BBEWGMJl1V5j0bHXc4t1ycD9hTDUXnj8tcqZH+tgaaT2vjUzBYSrDkF61zqLGgI3S8DCCxiz0OvlUeY81E8SgMa7yt64Q03Bur5/TBMYK+bVKD/AQ9UWoTpE6ApyPmF3u6jKG6z+54PAfR5zCQ9T8nerPWXgjn9SC/0ADZXTniSWtjQsDdzCpL3omNaF5QRxDCGcfnyqu4UcvOFTvQBI4DD4nQUAyryBtj7Y+ULT6bmKL3pcJb9xfvrT7zVjuHMfv84OMv56b5WnF+9WzWJWdhBhSfrIkFX+1Z8Dwsg7u0ise9ODlykaHaWRIh+gIMtWIgENyWYZnDKkAJOFcB+f4tS04RyspA1P9EczMHSWMbLUeYVSgWIiHKsbCApUODj1cT/BfiOa8dSbogwtDCEw=="
    attach_public_ip  = true
    private_static_ip = "192.168.0.10"
  }
}