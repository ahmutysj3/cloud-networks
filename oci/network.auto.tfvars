# Spoke VCN Params
spoke_vcns = {
  rick = {
    cidr = "10.1.2.0/24"
  }
  morty = {
    cidr = "10.1.3.0/24"
  }
  birdperson = {
    cidr = "10.1.4.0/24"
  }
}

# Spoke Subnet Params
spoke_subnets = {
  rickadmin = {
    cidr     = "10.1.2.0/28"
    private  = false
    vcn      = "rick"
    instance = "linux"
  }
  rickprimary = {
    cidr     = "10.1.2.16/28"
    private  = false
    vcn      = "rick"
    instance = null
  }
  rickbackup = {
    cidr     = "10.1.2.32/28"
    private  = false
    vcn      = "rick"
    instance = null
  }
  mortyadmin = {
    cidr     = "10.1.3.0/28"
    private  = false
    vcn      = "morty"
    instance = "linux"
  }
  mortyprimary = {
    cidr     = "10.1.3.16/28"
    private  = false
    vcn      = "morty"
    instance = null
  }
  mortybackup = {
    cidr     = "10.1.3.32/28"
    private  = false
    vcn      = "morty"
    instance = null
  }
  birdadmin = {
    cidr     = "10.1.4.0/28"
    private  = false
    vcn      = "birdperson"
    instance = "linux"
  }
  birdprimary = {
    cidr     = "10.1.4.16/28"
    private  = false
    vcn      = "birdperson"
    instance = null
  }
  birdbackup = {
    cidr     = "10.1.4.32/28"
    private  = false
    vcn      = "birdperson"
    instance = null
  }
}

