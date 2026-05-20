# Define a virtual network for your virtual machines
resource "openstack_networking_network_v2" "vm_network" {
  name           = "vm_network"           # The name of the network
  admin_state_up = true                   # Ensure the network is enabled
}

# Define a subnet within the virtual network
resource "openstack_networking_subnet_v2" "vm_subnet" {
  name            = "vm_subnet"           # Name of the subnet
  network_id      = openstack_networking_network_v2.vm_network.id   # Associate subnet with the network
  cidr            = "192.168.10.0/24"     # The subnet CIDR block for assigning IPs
  gateway_ip      = "192.168.10.1"        # The gateway IP for the subnet
  allocation_pool {                       # The pool of IP addresses available for the VMs
    start = "192.168.10.10"
    end   = "192.168.10.100"
  }
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]  # DNS servers for the subnet
}

# Define a router to connect the internal network to the external network (internet)
resource "openstack_networking_router_v2" "router" {
  name                = "router"
  admin_state_up      = true
  external_network_id = "9992655d-0892-4fe0-8a62-d9dac9044be2"  # The external network ID for internet access
}

# Connect the router to the subnet via a router interface
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id   # Associate the router
  subnet_id = openstack_networking_subnet_v2.vm_subnet.id  # Associate the subnet
}

#Create the SSH Keypair
resource "openstack_compute_keypair_v2" "vm_keypair" {
  name       = "new-ikt210-keypair"
  public_key = file("C:/Users/ayham/.ssh/new-ikt210-keypair.pub") 
}

# Create the SSH Keypair for teachers
resource "openstack_compute_keypair_v2" "teacher_keypair" {
  name       = "ikt210-teacher-keypair"
  public_key = file("C:/Users/ayham/.ssh/ikt210-g-24h.pub") 
}

# Cloud-init script to add both SSH keys to authorized_keys
data "template_file" "user_data" {
  template = <<EOF
#cloud-config
users:
  - default
  - name: ubuntu
    ssh-authorized-keys:
      - ${file("C:/Users/ayham/.ssh/new-ikt210-keypair.pub")}  
      - ${file("C:/Users/ayham/.ssh/ikt210-g-24h.pub")}   
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
EOF
}

# Create three virtual machines with the cloud-init script
resource "openstack_compute_instance_v2" "vm1" {
  name        = "vm1"
  flavor_name = "medium"
  image_name  = "ubuntu-noble"
  key_pair    = openstack_compute_keypair_v2.vm_keypair.name 
  network {
    uuid = openstack_networking_network_v2.vm_network.id
  }
  user_data = data.template_file.user_data.rendered  # Attach the cloud-init script
}

resource "openstack_compute_instance_v2" "vm2" {
  name        = "vm2"
  flavor_name = "medium"
  image_name  = "ubuntu-noble"
  key_pair    = openstack_compute_keypair_v2.vm_keypair.name
  network {
    uuid = openstack_networking_network_v2.vm_network.id
  }
  user_data = data.template_file.user_data.rendered
}

resource "openstack_compute_instance_v2" "vm3" {
  name        = "vm3"
  flavor_name = "medium"
  image_name  = "ubuntu-noble"
  key_pair    = openstack_compute_keypair_v2.vm_keypair.name
  network {
    uuid = openstack_networking_network_v2.vm_network.id
  }
  user_data = data.template_file.user_data.rendered
}


# Assign a floating IP to VM1
resource "openstack_networking_floatingip_v2" "floating_ip1" {
  pool = "provider"  # External network name
}

resource "openstack_networking_floatingip_associate_v2" "vm1_floating_ip" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip1.address
  port_id     = openstack_compute_instance_v2.vm1.network.0.port  # Fetch the correct port ID
}

# Assign a floating IP to VM2
resource "openstack_networking_floatingip_v2" "floating_ip2" {
  pool = "provider"
}

resource "openstack_networking_floatingip_associate_v2" "vm2_floating_ip" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip2.address
  port_id     = openstack_compute_instance_v2.vm2.network.0.port
}

# Assign a floating IP to VM3
resource "openstack_networking_floatingip_v2" "floating_ip3" {
  pool = "provider"
}

resource "openstack_networking_floatingip_associate_v2" "vm3_floating_ip" {
  floating_ip = openstack_networking_floatingip_v2.floating_ip3.address
  port_id     = openstack_compute_instance_v2.vm3.network.0.port
}
