nsg_vcn = { # copy key from var.spoke_vcn
  birdperson = {
    kafka_nsg      = true
    mgmt_nsg       = true
    prometheus_nsg = true
    smb_nsg        = false
    openvpn_nsg    = false
  }
  rick = {
    kafka_nsg      = true
    mgmt_nsg       = true
    prometheus_nsg = true
    smb_nsg        = true
    openvpn_nsg    = true
  }
  morty = {
    kafka_nsg      = false
    mgmt_nsg       = false
    prometheus_nsg = false
    smb_nsg        = false
    openvpn_nsg    = false
    allow_all      = true
  }
}