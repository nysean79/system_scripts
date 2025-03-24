# This script creates a customer gateway, and an IPSEC Site-to-Site connection between AWS in us-east-1 for the connection of YOUR.IP.ADDRESS.HERE

provider "aws" {

  region = "us-east-1" # Change this to your preferred AWS region

}

resource "aws_customer_gateway" "VPN_GATEWAY_ENDPOINT_0001" {

  bgp_asn    = 65000
  ip_address = "YOUR.IP.ADDRESS.HERE" # Replace with your on-premises public IP address
  type       = "ipsec.1"
  tags = {
    Name = "VPN_GATEWAY_ENDPOINT_0"
  }
}

# Tunnel(s) Options 

resource "aws_vpn_connection" "VPN_TUNNEL_0001_IPSEC_S2S_SETTINGS_0" {
  
  customer_gateway_id = aws_customer_gateway.VPN_GATEWAY_ENDPOINT_0.id
  type                = "ipsec.1"  # IPSec tunnel type
  static_routes_only  = true
# Tunnel 1
# Phase 1
  tunnel1_preshared_key = "yourprivatekeyhere_1"
  tunnel1_ike_versions = [ "ikev2" ]
  tunnel1_phase1_encryption_algorithms = [ "AES256" ]
  tunnel1_phase1_integrity_algorithms = [ "SHA2-256" ]
  tunnel1_phase1_dh_group_numbers = [ "20" ]
  tunnel1_phase1_lifetime_seconds = "28800"
# Phase 2
  tunnel1_phase2_encryption_algorithms = [ "AES256" ]
  tunnel1_phase2_integrity_algorithms = [ "SHA2-256" ]
  tunnel1_phase2_dh_group_numbers = [ "20" ]
  tunnel1_phase2_lifetime_seconds = "3600" # This can only be between 900 and 3600 
# Tunnel 2
# Phase 1
  tunnel2_ike_versions = [ "ikev2" ]
  tunnel2_preshared_key = "yourprivatekeyhere_2"
  tunnel2_phase1_encryption_algorithms = [ "AES256" ]
  tunnel2_phase1_integrity_algorithms = [ "SHA2-256" ]
  tunnel2_phase1_dh_group_numbers = [ "20" ]
  tunnel2_phase1_lifetime_seconds = "28800"
# Phase 2
  tunnel2_phase2_encryption_algorithms = [ "AES256" ]
  tunnel2_phase2_integrity_algorithms = [ "SHA2-256" ]
  tunnel2_phase2_dh_group_numbers = [ "20" ]
  tunnel2_phase2_lifetime_seconds = "3600" # This can only be between 900 and 3600 #
  tags = {
    Name = "VPN_TUNNEL_0001_IPSEC_S2S_SETTINGS_0"
  }

}
