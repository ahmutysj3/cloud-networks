# trace-oci-tf-public
Oracle Cloud Infrastruction Terraform Plan for VCN Environment


Note: this tf plan only works if you have properly configured the oci provider config file and exported tenancy_ocid as a environmental variable

The backend storage relies on my own s3 bucket so that would also need to be modified prior to running the apply