# GCP Deployment Guide

Complete guide for deploying RHIS components on Google Cloud Platform.

## GCP Prerequisites

### GCP Account Setup

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash

# Initialize gcloud
gcloud init

# Set project
gcloud config set project PROJECT_ID
```

### Service Account

```bash
# Create service account
gcloud iam service-accounts create rhis-deployer \
  --display-name="RHIS Deployment Account"

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:rhis-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:rhis-deployer@PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/container.admin"

# Create key
gcloud iam service-accounts keys create key.json \
  --iam-account=rhis-deployer@PROJECT_ID.iam.gserviceaccount.com
```

## Networking

### VPC and Subnets

```bash
# Create VPC network
gcloud compute networks create rhis-network \
  --subnet-mode=custom

# Create subnets
gcloud compute networks subnets create rhis-management \
  --network=rhis-network \
  --region=us-central1 \
  --range=10.0.1.0/24

gcloud compute networks subnets create rhis-databases \
  --network=rhis-network \
  --region=us-central1 \
  --range=10.0.2.0/24

gcloud compute networks subnets create rhis-execution \
  --network=rhis-network \
  --region=us-central1 \
  --range=10.0.3.0/24
```

### Firewall Rules

```bash
# Create firewall rule for HTTP/HTTPS
gcloud compute firewall-rules create rhis-allow-http \
  --network=rhis-network \
  --allow=tcp:80,tcp:443 \
  --source-ranges=0.0.0.0/0

# Create firewall rule for SSH
gcloud compute firewall-rules create rhis-allow-ssh \
  --network=rhis-network \
  --allow=tcp:22 \
  --source-ranges=10.0.0.0/16

# Create firewall rule for internal traffic
gcloud compute firewall-rules create rhis-allow-internal \
  --network=rhis-network \
  --allow=tcp,udp \
  --source-ranges=10.0.0.0/16
```

## Compute Instances

### Create VMs

```bash
# Create AAP instance
gcloud compute instances create aap-controller \
  --zone=us-central1-a \
  --machine-type=n2-standard-8 \
  --network-interface=network=rhis-network,subnet=rhis-management \
  --boot-disk-size=100GB \
  --boot-disk-type=pd-ssd \
  --image-family=rhel-9 \
  --image-project=rhel-cloud \
  --metadata=enable-oslogin=TRUE

# Create Satellite instance
gcloud compute instances create satellite \
  --zone=us-central1-a \
  --machine-type=n2-standard-16 \
  --network-interface=network=rhis-network,subnet=rhis-management \
  --boot-disk-size=500GB \
  --boot-disk-type=pd-ssd \
  --image-family=rhel-9 \
  --image-project=rhel-cloud \
  --metadata=enable-oslogin=TRUE

# Create IdM instance
gcloud compute instances create idm \
  --zone=us-central1-a \
  --machine-type=n2-standard-8 \
  --network-interface=network=rhis-network,subnet=rhis-management \
  --boot-disk-size=50GB \
  --boot-disk-type=pd-ssd \
  --image-family=rhel-9 \
  --image-project=rhel-cloud \
  --metadata=enable-oslogin=TRUE
```

### Machine Types

```
AAP Controller:
  Small: n2-standard-8 (8 vCPU, 32 GB RAM)
  Medium: n2-standard-16 (16 vCPU, 64 GB RAM)
  Large: n2-standard-32 (32 vCPU, 128 GB RAM)

Satellite:
  Small: n2-standard-16 (16 vCPU, 64 GB RAM)
  Medium: n2-standard-32 (32 vCPU, 128 GB RAM)
  Large: n2-standard-64 (64 vCPU, 256 GB RAM)

IdM:
  Small: n2-standard-8 (8 vCPU, 32 GB RAM)
  Medium: n2-standard-16 (16 vCPU, 64 GB RAM)
```

## Persistent Disks

### Create Additional Disks

```bash
# Create disk for Satellite repos
gcloud compute disks create satellite-repos \
  --size=1000GB \
  --zone=us-central1-a \
  --type=pd-ssd

# Attach to Satellite instance
gcloud compute instances attach-disk satellite \
  --disk=satellite-repos \
  --zone=us-central1-a

# Create disk for AAP data
gcloud compute disks create aap-data \
  --size=500GB \
  --zone=us-central1-a \
  --type=pd-ssd

# Attach to AAP instance
gcloud compute instances attach-disk aap-controller \
  --disk=aap-data \
  --zone=us-central1-a
```

## Cloud SQL

### Managed Database

```bash
# Create Cloud SQL instance
gcloud sql instances create rhis-db \
  --database-version=POSTGRES_14 \
  --tier=db-custom-8-32768 \
  --region=us-central1 \
  --network=rhis-network \
  --backup \
  --backup-start-time=02:00 \
  --retained-backups-count=30 \
  --transaction-log-retention-days=7

# Create databases
gcloud sql databases create awx \
  --instance=rhis-db

gcloud sql databases create foreman \
  --instance=rhis-db

gcloud sql databases create ipa \
  --instance=rhis-db

# Create users
gcloud sql users create awx \
  --instance=rhis-db \
  --password=AWXPassword123!

gcloud sql users create foreman \
  --instance=rhis-db \
  --password=ForemanPassword123!

gcloud sql users create ipa \
  --instance=rhis-db \
  --password=IPAPassword123!
```

## Load Balancer

### Setup HTTP(S) Load Balancer

```bash
# Create health check
gcloud compute health-checks create https aap-health-check \
  --request-path=/api/v2/ \
  --port=443

# Create backend service
gcloud compute backend-services create aap-backend \
  --global \
  --protocol=HTTPS \
  --port-name=https \
  --health-checks=aap-health-check

# Create instance group
gcloud compute instance-groups create aap-group \
  --zone=us-central1-a

# Add instances to group
gcloud compute instance-groups add-instances aap-group \
  --instances=aap-controller \
  --zone=us-central1-a

# Add group to backend service
gcloud compute backend-services add-backend aap-backend \
  --instance-group=aap-group \
  --global \
  --instance-group-zone=us-central1-a

# Create URL map
gcloud compute url-maps create aap-map \
  --default-service=aap-backend

# Create HTTPS proxy
gcloud compute target-https-proxies create aap-proxy \
  --url-map=aap-map \
  --ssl-certificates=rhis-ssl-cert

# Create forwarding rule
gcloud compute forwarding-rules create aap-forwarding-rule \
  --global \
  --target-https-proxy=aap-proxy \
  --address=rhis-ip \
  --ports=443
```

## Cloud Monitoring

### Setup Monitoring

```bash
# Create notification channel
gcloud alpha monitoring channels create \
  --display-name="RHIS Alerts" \
  --type=email \
  --channel-labels=email_address=ops@example.com

# Create alert policy
gcloud alpha monitoring policies create \
  --notification-channels=CHANNEL_ID \
  --display-name="High CPU Usage" \
  --condition-display-name="CPU > 80%" \
  --condition-query='resource.type="gce_instance" AND metric.type="compute.googleapis.com/instance/cpu/utilization" AND metric.value > 0.8'
```

## Cloud Storage for Backups

### Setup Backup Storage

```bash
# Create bucket
gsutil mb -l us-central1 gs://rhis-backups-$(date +%s)

# Enable versioning
gsutil versioning set on gs://rhis-backups-xxx

# Set lifecycle policy
cat > lifecycle.json <<EOF
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://rhis-backups-xxx

# Sync backups
gsutil rsync -r /backup gs://rhis-backups-xxx/backups/
```

## DNS

### Cloud DNS

```bash
# Create managed zone
gcloud dns managed-zones create rhis-zone \
  --dns-name=example.com. \
  --description="RHIS DNS Zone"

# Create A record for AAP
gcloud dns record-sets create aap.example.com. \
  --rrdatas=10.0.1.10 \
  --ttl=300 \
  --type=A \
  --zone=rhis-zone

# Create A record for Satellite
gcloud dns record-sets create satellite.example.com. \
  --rrdatas=10.0.1.20 \
  --ttl=300 \
  --type=A \
  --zone=rhis-zone

# Create A record for IdM
gcloud dns record-sets create idm.example.com. \
  --rrdatas=10.0.1.30 \
  --ttl=300 \
  --type=A \
  --zone=rhis-zone
```

## Kubernetes (GKE) Option

### Deploy to GKE

```bash
# Create GKE cluster
gcloud container clusters create rhis-cluster \
  --zone=us-central1-a \
  --num-nodes=3 \
  --machine-type=n2-standard-8 \
  --network=rhis-network \
  --subnetwork=rhis-management \
  --enable-autoscaling \
  --min-nodes=3 \
  --max-nodes=10

# Deploy AAP via Kubernetes
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aap-controller
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aap
  template:
    metadata:
      labels:
        app: aap
    spec:
      containers:
      - name: controller
        image: quay.io/ansible/controller:latest
        ports:
        - containerPort: 443
        resources:
          requests:
            memory: "16Gi"
            cpu: "4"
EOF
```

## Cost Optimization

### Recommendations

```bash
# Use committed use discounts
gcloud compute commit-requests create \
  --machine-type=n2-standard-8 \
  --region=us-central1 \
  --purchase-plan=1-YEAR

# Use preemptible instances for test workloads
gcloud compute instances create test-vm \
  --zone=us-central1-a \
  --preemptible \
  --machine-type=n2-standard-4

# Monitor costs
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="RHIS Budget" \
  --budget-amount=10000
```

---

See [Deployment Overview](./OVERVIEW.md) for general deployment concepts and [Operations](../operations/) for running RHIS on GCP.
