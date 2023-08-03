nsg_params = {

  kafka_nsg = {

    rules = {
      birdadmin_basic_access = {
        description = "Allows multiple types of traffic from the birdadmin subnet"
        source_type = "cidr"
        allow_from  = "10.1.4.0/28"
        ports = {
          dns = {
            protocol = "udp"
            min      = 53
            max      = 53
            type     = null
            code     = null
          }

          ssh = {
            protocol = "tcp"
            min      = 22
            max      = 22
            type     = null
            code     = null
          }
        }
      }

      rick_rdp_access = {
        description = "Allows rdp traffic from rick admin subnet"
        source_type = "subnet"
        allow_from  = "rickadmin"
        ports = {
          rdp = {
            protocol = "tcp"
            min      = 3389
            max      = 3389
            type     = null
            code     = null
          }
        }
      }

      morty_ping_reply_access = {
        description = "Allows echo reply from morty vcn"
        source_type = "vcn"
        allow_from  = "morty"
        ports = {
          echo_reply = {
            protocol = "icmp"
            min      = null
            max      = null
            type     = 0
            code     = null
          }
        }
      }

      datacenter_snmp_access = {
        description = "Allows snmp traps and informs from datacenter"
        source_type = "datacenter"
        allow_from  = null
        ports = {
          admin_access_snmp = {
            protocol = "udp"
            min      = 161
            max      = 162
            type     = null
            code     = null
          }
        }
      }
    }
  }
} 