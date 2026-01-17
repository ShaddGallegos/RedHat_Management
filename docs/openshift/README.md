# Red Hat OpenShift Container Platform 4.21

## Synopsis

Red Hat OpenShift Container Platform is a comprehensive enterprise Kubernetes platform built on open source technologies. OpenShift 4.21 provides:

- **Kubernetes Orchestration** - Production-grade container orchestration
- **Developer Experience** - Built-in developer tools and CI/CD
- **Container Registry** - Integrated image registry and management
- **Service Mesh** - Istio integration for service communication
- **Monitoring & Logging** - Integrated Prometheus and ELK stack
- **Security** - RBAC, network policies, pod security standards
- **Multi-tenancy** - Project-based resource isolation

Deployed via RHIS, OpenShift provides the platform for containerized applications across your infrastructure.

---

## Quick Start

### Prerequisites
- 3 control plane nodes (minimum)
- 3 compute nodes (minimum)
- Each node: RHEL 9.x, 16GB RAM, 4 vCPU, 100GB storage
- Static DNS entries for cluster
- Network connectivity to Red Hat registries

### 1. Configure Inventory
Update `inventory/openshift.yml`:
```yaml
[ocp_masters]
ocp-master1.example.com
ocp-master2.example.com
ocp-master3.example.com

[ocp_workers]
ocp-worker1.example.com
ocp-worker2.example.com
ocp-worker3.example.com

[ocp_all:children]
ocp_masters
ocp_workers

[ocp_all:vars]
ocp_cluster_name=production
ocp_base_domain=example.com
ocp_version=4.21
```

### 2. Configure Settings
Edit `group_vars/openshift.yml`:
```yaml
ocp_version: "4.21"
ocp_cluster_name: "production"
ocp_base_domain: "example.com"
ocp_api_vip: "192.168.1.100"
ocp_ingress_vip: "192.168.1.101"
```

### 3. Deploy OpenShift
```bash
ansible-playbook site.yml -t openshift
```

### 4. Access OpenShift
- **Console**: https://console-openshift-console.apps.production.example.com
- **API**: https://api.production.example.com:6443
- **Default Admin**: kubeadmin (password in deployment logs)

---

## Installation

### Detailed Installation Steps

#### Step 1: System Preparation
```bash
# Update all nodes
yum update -y

# Install required packages
yum install -y \
  bind-utils \
  git \
  jq \
  python39 \
  libvirt-libs \
  rsync

# Configure firewall on all nodes
firewall-cmd --permanent --add-port=6443/tcp  # API
firewall-cmd --permanent --add-port=22623/tcp # Machine config
firewall-cmd --permanent --add-port=80/tcp    # HTTP
firewall-cmd --permanent --add-port=443/tcp   # HTTPS
firewall-cmd --permanent --add-port=4789/udp  # VXLAN
firewall-cmd --permanent --add-port=6081/udp  # GENEVE
firewall-cmd --reload

# Disable swap
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# Load required kernel modules
cat >> /etc/modules-load.d/crio.conf << EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Set sysctl parameters
cat >> /etc/sysctl.d/99-kubernetes-cri.conf << EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
net.ipv6.conf.all.forwarding        = 1
EOF

sysctl --system
```

#### Step 2: Pre-Installation Configuration
```bash
# Create installation directory
mkdir -p /opt/openshift-install
cd /opt/openshift-install

# Download installer
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.21/openshift-install-linux.tar.gz
tar xzf openshift-install-linux.tar.gz

# Download kubectl
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.21/kubectl-linux.tar.gz
tar xzf kubectl-linux.tar.gz
cp kubectl /usr/local/bin/

# Create install-config.yaml
cat > install-config.yaml << EOF
apiVersion: v1
baseDomain: example.com
compute:
- hyperthreading: Enabled
  name: worker
  replicas: 3
  resources:
    requests:
      cpu: 4
      memory: 16Gi
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
  resources:
    requests:
      cpu: 4
      memory: 16Gi
metadata:
  name: production
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.0.0/16
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.30.0.0/16
platform:
  libvirt:
    network:
      if: br0
pullSecret: '{"auths":{"cloud.openshift.com":{...}}}'
sshKey: 'ssh-rsa AAAAB3...'
EOF
```

#### Step 3: Run Installation Role
```bash
# Deploy OpenShift via role
ansible-playbook -i inventory/openshift.yml \
  roles/openshift_4_21_deployment/tasks/main.yml \
  --vault-password-file ~/.ansible/conf/vault.txt

# Or full playbook
ansible-playbook site.yml \
  -e "deployment_scenario=openshift" \
  --tags openshift
```

#### Step 4: Create Installation Manifests
```bash
cd /opt/openshift-install

./openshift-install create manifests --dir=cluster

# Modify manifests if needed
sed -i 's/mastersSchedulable: true/mastersSchedulable: false/' cluster/manifests/cluster-scheduler-02-config.yml
```

#### Step 5: Create Ignition Configs
```bash
cd /opt/openshift-install

./openshift-install create ignition-configs --dir=cluster

# Verify configs
ls -la cluster/*.ign
```

#### Step 6: Start Cluster
```bash
# Start control plane nodes
for i in 1 2 3; do
  virsh start ocp-master$i
done

# Monitor bootstrap
./openshift-install wait-for bootstrap-complete --dir=cluster --log-level=info

# Start worker nodes
for i in 1 2 3; do
  virsh start ocp-worker$i
done

# Wait for installation complete
./openshift-install wait-for install-complete --dir=cluster --log-level=info
```

#### Step 7: Verification
```bash
# Get kubeconfig
export KUBECONFIG=/opt/openshift-install/cluster/auth/kubeconfig

# Check cluster status
kubectl get nodes

# Check operator status
kubectl get clusteroperators

# Verify API
kubectl cluster-info
```

---

## Integration with RHIS Project

### 1. Credential Management
```yaml
# group_vars/vault.yml
vault_ocp_pull_secret: |
  {"auths":{"cloud.openshift.com":{...}}}
vault_ocp_ssh_key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

### 2. Cluster Configuration
```yaml
# playbooks/configure_ocp.yml
---
- name: Configure OpenShift Cluster
  hosts: localhost
  
  vars:
    kubeconfig: /opt/openshift-install/cluster/auth/kubeconfig
  
  tasks:
    - name: Add HTPasswd identity provider
      kubernetes.core.k8s:
        kubeconfig: "{{ kubeconfig }}"
        state: present
        definition:
          apiVersion: config.openshift.io/v1
          kind: OAuth
          metadata:
            name: cluster
          spec:
            identityProviders:
            - name: htpasswd_provider
              challenge: true
              login: true
              provider:
                apiVersion: v1
                kind: HTPasswdPasswordIdentityProvider
                file: /etc/oauth/htpasswd
    
    - name: Create admin user
      kubernetes.core.k8s:
        kubeconfig: "{{ kubeconfig }}"
        state: present
        definition:
          apiVersion: rbac.authorization.k8s.io/v1
          kind: ClusterRoleBinding
          metadata:
            name: cluster-admin
          subjects:
          - kind: User
            name: admin
          roleRef:
            kind: ClusterRole
            name: cluster-admin
            apiGroup: rbac.authorization.k8s.io
```

### 3. Project Management
```yaml
# playbooks/create_ocp_project.yml
---
- name: Create OpenShift Projects
  hosts: localhost
  
  tasks:
    - name: Create project
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: project.openshift.io/v1
          kind: Project
          metadata:
            name: production
      
    - name: Set resource quotas
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: ResourceQuota
          metadata:
            name: production-quota
            namespace: production
          spec:
            hard:
              requests.cpu: "100"
              requests.memory: "200Gi"
              limits.cpu: "200"
              limits.memory: "400Gi"
              pods: "100"
```

---

## Update & Upgrade

### Prepare for Upgrade
```bash
# 1. Back up cluster data
kubectl get all -A -o yaml > cluster_backup_$(date +%Y%m%d).yaml

# 2. Check current version
kubectl get clusterversion

# 3. Review upgrade documentation
./openshift-install explain clusterversion
```

### Upgrade Process
```bash
# Trigger cluster upgrade
kubectl patch clusterversion version --type merge \
  -p '{"spec":{"desiredUpdate":{"version":"4.21.5"}}}'

# Monitor upgrade
kubectl get clusterversion -o json | jq '.items[0].status'

# Watch node updates
kubectl get nodes --watch
```

### Post-Upgrade Verification
```bash
# Verify all operators
kubectl get clusteroperators

# Check node status
kubectl get nodes

# Verify workloads
kubectl get pods -A | grep -E "ERROR|Pending"
```

---

## Examples

### Example 1: Deploy Application
```yaml
---
- name: Deploy Application to OpenShift
  hosts: localhost
  
  tasks:
    - name: Create deployment
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: web-server
            namespace: production
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: web-server
            template:
              metadata:
                labels:
                  app: web-server
              spec:
                containers:
                - name: nginx
                  image: quay.io/fedora/nginx:latest
                  ports:
                  - containerPort: 80
                  resources:
                    requests:
                      cpu: "100m"
                      memory: "128Mi"
                    limits:
                      cpu: "500m"
                      memory: "512Mi"
    
    - name: Create service
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: web-server-svc
            namespace: production
          spec:
            type: LoadBalancer
            selector:
              app: web-server
            ports:
            - protocol: TCP
              port: 80
              targetPort: 80
    
    - name: Create route
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: route.openshift.io/v1
          kind: Route
          metadata:
            name: web-server-route
            namespace: production
          spec:
            host: web-server.apps.production.example.com
            to:
              kind: Service
              name: web-server-svc
```

### Example 2: Configure Network Policy
```yaml
---
- name: Configure Network Policies
  hosts: localhost
  
  tasks:
    - name: Create network policy
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: networking.k8s.io/v1
          kind: NetworkPolicy
          metadata:
            name: deny-external
            namespace: production
          spec:
            podSelector:
              matchLabels:
                app: web-server
            policyTypes:
            - Ingress
            - Egress
            ingress:
            - from:
              - podSelector:
                  matchLabels:
                    app: frontend
              ports:
              - protocol: TCP
                port: 80
            egress:
            - to:
              - podSelector:
                  matchLabels:
                    app: database
              ports:
              - protocol: TCP
                port: 5432
```

### Example 3: Storage Configuration
```yaml
---
- name: Configure Persistent Storage
  hosts: localhost
  
  tasks:
    - name: Create persistent volume claim
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: PersistentVolumeClaim
          metadata:
            name: database-storage
            namespace: production
          spec:
            accessModes:
            - ReadWriteOnce
            resources:
              requests:
                storage: 100Gi
            storageClassName: fast-ssd
    
    - name: Create stateful set with storage
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: StatefulSet
          metadata:
            name: postgres
            namespace: production
          spec:
            serviceName: postgres
            replicas: 1
            selector:
              matchLabels:
                app: postgres
            template:
              metadata:
                labels:
                  app: postgres
              spec:
                containers:
                - name: postgres
                  image: postgres:13
                  volumeMounts:
                  - name: data
                    mountPath: /var/lib/postgresql/data
            volumeClaimTemplates:
            - metadata:
                name: data
              spec:
                accessModes: [ "ReadWriteOnce" ]
                resources:
                  requests:
                    storage: 100Gi
```

### Example 4: RBAC Configuration
```bash
#!/bin/bash
# scripts/bash/configure_ocp_rbac.sh

KUBECONFIG=/opt/openshift-install/cluster/auth/kubeconfig

# Create developer role
kubectl create role developer \
  --verb=create,update,patch,get,list,watch \
  --resource=pods,services,deployments \
  -n production

# Create role binding
kubectl create rolebinding developer-binding \
  --clusterrole=developer \
  --user=developer@example.com \
  -n production

# Create service account
kubectl create serviceaccount app-deployer -n production

# Create cluster role binding for service account
kubectl create clusterrolebinding app-deployer \
  --clusterrole=cluster-admin \
  --serviceaccount=production:app-deployer
```

### Example 5: Monitoring Setup
```yaml
---
- name: Deploy Monitoring Stack
  hosts: localhost
  
  tasks:
    - name: Create monitoring namespace
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Namespace
          metadata:
            name: monitoring
    
    - name: Deploy Prometheus
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: ConfigMap
          metadata:
            name: prometheus-config
            namespace: monitoring
          data:
            prometheus.yml: |
              global:
                scrape_interval: 15s
              scrape_configs:
              - job_name: kubernetes
                kubernetes_sd_configs:
                - role: node
```

---

## Troubleshooting

### Issue: Nodes Not Ready
```bash
# Check node status
kubectl describe node <node-name>

# Check kubelet logs
journalctl -u kubelet -f

# Verify network connectivity
kubectl get network -o yaml
```

### Issue: Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# View pod logs
kubectl logs <pod-name> -n <namespace>

# Check resource availability
kubectl top nodes
kubectl top pods -n <namespace>
```

### Issue: Persistent Volume Claim Stuck
```bash
# Check PVC status
kubectl describe pvc <pvc-name> -n <namespace>

# Check storage class
kubectl get storageclass

# Check available PVs
kubectl get pv
```

---

## Additional Resources

- [OpenShift Documentation](https://docs.openshift.com/container-platform/4.21/)
- [Red Hat Learning](https://learning.redhat.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [RHIS Project Guide](../README.md)
- [Related: Libvirt Infrastructure](../libvirt/README.md)

---

**Last Updated:** January 2026
**Supported Versions:** OpenShift 4.21.x
**RHIS Compatibility:** Libvirt (primary), AWS, Azure, VMware, Nutanix
