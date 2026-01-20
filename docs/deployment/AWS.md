# AWS Deployment Guide

Complete guide for deploying RHIS components on Amazon Web Services.

## AWS Prerequisites

### AWS Account Setup

```bash
# Install AWS CLI
pip install awscli

# Configure credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Default region, Output format
```

### IAM Permissions

Required IAM policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "rds:*",
        "route53:*",
        "s3:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### VPC and Network

```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create subnets
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.2.0/24 --availability-zone us-east-1b

# Create security groups
aws ec2 create-security-group \
  --group-name rhis-sg \
  --description "RHIS Security Group" \
  --vpc-id vpc-xxx

# Allow inbound ports
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 22 \
  --cidr 10.0.0.0/16
```

## EC2 Instances

### Launch Instances

```bash
# Find RHEL 9 AMI
aws ec2 describe-images \
  --owners 309956199498 \
  --filters "Name=name,Values=RHEL-9*x86_64*"

# Launch AAP instance
aws ec2 run-instances \
  --image-id ami-0c94855ba95c574c8 \
  --instance-type c5.2xlarge \
  --key-name my-key \
  --security-group-ids sg-xxx \
  --subnet-id subnet-xxx \
  --block-device-mappings \
    DeviceName=/dev/xvda,Ebs={VolumeSize=100,VolumeType=gp3} \
  --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=aap-controller}]"

# Launch Satellite instance
aws ec2 run-instances \
  --image-id ami-0c94855ba95c574c8 \
  --instance-type c5.4xlarge \
  --key-name my-key \
  --security-group-ids sg-xxx \
  --subnet-id subnet-xxx \
  --block-device-mappings \
    DeviceName=/dev/xvda,Ebs={VolumeSize=500,VolumeType=gp3} \
  --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=scenario_satellite}]"

# Launch IdM instance
aws ec2 run-instances \
  --image-id ami-0c94855ba95c574c8 \
  --instance-type m5.2xlarge \
  --key-name my-key \
  --security-group-ids sg-xxx \
  --subnet-id subnet-xxx \
  --block-device-mappings \
    DeviceName=/dev/xvda,Ebs={VolumeSize=50,VolumeType=gp3} \
  --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=idm}]"
```

### Instance Types Recommended

```
AAP Controller:
  Small: c5.2xlarge (8 vCPU, 16 GB RAM)
  Medium: c5.4xlarge (16 vCPU, 32 GB RAM)
  Large: c5.9xlarge (36 vCPU, 72 GB RAM)

Satellite:
  Small: c5.4xlarge (16 vCPU, 32 GB RAM, 500 GB SSD)
  Medium: c5.9xlarge (36 vCPU, 72 GB RAM, 1 TB SSD)
  Large: r5.12xlarge (48 vCPU, 384 GB RAM, 2 TB SSD)

IdM:
  Small: m5.2xlarge (8 vCPU, 32 GB RAM)
  Medium: m5.4xlarge (16 vCPU, 64 GB RAM)
```

## RDS Database

### Create RDS Instance

```bash
# Create RDS cluster (recommended for HA)
aws rds create-db-cluster \
  --db-cluster-identifier rhis-cluster \
  --engine aurora-postgresql \
  --engine-version 14.6 \
  --master-username postgres \
  --master-user-password SecurePassword123! \
  --vpc-security-group-ids sg-xxx \
  --db-subnet-group-name default \
  --backup-retention-period 30 \
  --enable-cloudwatch-logs-exports postgresql \
  --storage-encrypted

# Create cluster instances
aws rds create-db-instance \
  --db-instance-identifier rhis-primary \
  --db-cluster-identifier rhis-cluster \
  --db-instance-class db.r5.2xlarge \
  --engine aurora-postgresql \
  --publicly-accessible false

aws rds create-db-instance \
  --db-instance-identifier rhis-replica \
  --db-cluster-identifier rhis-cluster \
  --db-instance-class db.r5.2xlarge \
  --engine aurora-postgresql \
  --publicly-accessible false
```

## Load Balancer

### Setup Application Load Balancer

```bash
# Create load balancer
aws elbv2 create-load-balancer \
  --name rhis-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx \
  --scheme internet-facing \
  --type application

# Create target group for AAP
aws elbv2 create-target-group \
  --name aap-tg \
  --protocol HTTPS \
  --port 443 \
  --vpc-id vpc-xxx \
  --health-check-protocol HTTPS \
  --health-check-path /api/v2/ \
  --matcher HttpCode=200,401

# Register AAP targets
aws elbv2 register-targets \
  --target-group-arn arn:aws:elasticloadbalancing:... \
  --targets Id=i-aap1 Id=i-aap2 Id=i-aap3

# Create listener
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:... \
  --protocol HTTPS \
  --port 443 \
  --certificate-arn arn:aws:acm:... \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:...
```

## Auto Scaling

### Setup Auto Scaling

```bash
# Create launch template
aws ec2 create-launch-template \
  --launch-template-name rhis-aap-template \
  --version-description "AAP launch template" \
  --launch-template-data '{
    "ImageId": "ami-xxx",
    "InstanceType": "c5.2xlarge",
    "KeyName": "my-key",
    "SecurityGroupIds": ["sg-xxx"],
    "UserData": "aW5pdC1zY3JpcHQ=..."
  }'

# Create auto scaling group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name rhis-aap-asg \
  --launch-template LaunchTemplateName=rhis-aap-template,Version='$Latest' \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 3 \
  --default-cooldown 300 \
  --target-group-arns arn:aws:elasticloadbalancing:...

# Create scaling policy
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name rhis-aap-asg \
  --policy-name cpu-scaling \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration file://scaling-policy.json
```

### Scaling Policy

```json
{
  "TargetValue": 70.0,
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "ScaleOutCooldown": 60,
  "ScaleInCooldown": 300
}
```

## S3 for Backups

### Setup S3 Bucket

```bash
# Create bucket
aws s3 mb s3://rhis-backups-$(date +%s)

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket rhis-backups-xxx \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket rhis-backups-xxx \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Set lifecycle policy (delete old backups after 90 days)
aws s3api put-bucket-lifecycle-configuration \
  --bucket rhis-backups-xxx \
  --lifecycle-configuration file://lifecycle.json
```

### Lifecycle Policy

```json
{
  "Rules": [
    {
      "Id": "DeleteOldBackups",
      "Status": "Enabled",
      "ExpirationInDays": 90,
      "NoncurrentVersionExpirationInDays": 30,
      "Prefix": "backups/"
    }
  ]
}
```

## DNS Setup

### Route 53 Configuration

```bash
# Create hosted zone
aws route53 create-hosted-zone \
  --name example.com \
  --caller-reference $(date +%s)

# Create A record for AAP
aws route53 change-resource-record-sets \
  --hosted-zone-id ZXXXXX \
  --change-batch file://aap-record.json
```

### DNS Records

```json
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "aap.example.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z35SXDOTRQ7X7K",
          "DNSName": "rhis-alb-xxx.us-east-1.elb.amazonaws.com",
          "EvaluateTargetHealth": true
        }
      }
    },
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "scenario_satellite.example.com",
        "Type": "A",
        "TTL": 300,
        "ResourceRecords": [{"Value": "10.0.1.50"}]
      }
    }
  ]
}
```

## CloudWatch Monitoring

### Setup CloudWatch

```bash
# Create custom metric for job success rate
aws cloudwatch put-metric-alarm \
  --alarm-name aap-job-failures \
  --alarm-description "Alert on AAP job failures" \
  --metric-name JobFailures \
  --namespace RHIS/AAP \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:us-east-1:xxx:rhis-alerts

# Create dashboard
aws cloudwatch put-dashboard \
  --dashboard-name RHIS-Dashboard \
  --dashboard-body file://dashboard.json
```

## Deployment Ansible Playbook

```yaml
---
- name: Deploy RHIS on AWS
  hosts: localhost
  gather_facts: no
  tasks:
    - name: Create AWS platform_infrastructure_core
      terraform:
        project_path: './terraform'
        state: present
      register: tf_output

    - name: Wait for instances
      pause:
        minutes: 2

    - name: Run RHIS installation
      command: ansible-playbook redhat_management-site.yml -i aws_ec2.yml
```

---

See [Deployment Overview](./OVERVIEW.md) for general deployment concepts and [Operations](../operations/) for running RHIS on AWS.
