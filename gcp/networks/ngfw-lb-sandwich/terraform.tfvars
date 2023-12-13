
gcp_project           = "terraform-project-trace-lab"
gcp_region            = "us-east1"
hc_port               = 8008
web_subnets           = ["tracecloud", "birdperson", "squanchy"]
pfsense_name          = "pfsense-active-fw"
pfsense_machine_image = "pfsense-master"
deploy_fortigate      = false
boot_disk_size        = 100
default_fw_route      = true
deploy_pfsense        = true
ilb_next_hop          = true
