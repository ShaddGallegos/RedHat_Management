# Architecture - System Overview

High-level architecture and design of RHIS.

## System Components

```

                    Red Hat Management Stack                 

                                                               
            
       AAP          Satellite          IdM            
     2.6             6.18            3.0             
            
                                                          
                        
                                                             
                                          
                     Integration                           
                     Layer (APIs)                          
                                          
                                                             
         
                                                         
                                                         
 OpenShift            Monitoring                  CMDB      
  4.21               & Logging               (ansible-scenario_ansible_cmdb_core) 
                                                             

           Infrastructure Layer (libvirt, cloud, etc.)      

                      Networking & Storage                   

```

## Product Interactions

### Satellite → AAP Integration

- Satellite provides inventory for AAP
- AAP executes remediation via Satellite
- Satellite tracks configuration state

### AAP ↔ IdM Integration  

- IdM provides centralized authentication
- AAP uses IdM for user management
- IdM authenticates to AAP console

### Satellite ↔ IdM Integration

- IdM provides authentication for Satellite UI
- Satellite configures IdM clients
- User accounts managed centrally

### Integration to OpenShift

- AAP provisions OpenShift cluster (optional)
- OpenShift hosts container workloads
- Containers integrate with AAP, Satellite, IdM

## Deployment Scenarios

### Satellite-Only
- Single-product deployment
- Systems management and platform_provisioning
- Minimal resource requirements

### AAP-Only
- Automation platform only
- Task automation and ansible_dev_node_orchestration  
- Scalable to any platform_infrastructure_core

### Full Stack
- All 4 products deployed
- Fully integrated management solution
- Maximum capabilities

## High-Availability Design

```

      Load Balancer              

                                  

                                 
                                 
Node-1        Node-2            Node-3
- AAP         - AAP              - AAP
- Satellite   - Satellite        - Satellite
- IdM         - IdM              - IdM

Shared DB (PostgreSQL cluster)
Shared Storage (NFS, S3, etc.)
```

---

See [Architecture](../architecture/) for detailed design documents.
