## Creating a scale set with and autoscaling with autoscaler

What we need
- Resource Group
- Virtual Network
- Subnet
    - Network Security Group
- Machine Scale Set
    - Virtual Machine
    - Network interface configured with backend ip address pool
- Monitor Autoscale setting
- Load Balancer
    - Backend ip address pool
    - Frontend ip configuration configured with public ip
- Public IP