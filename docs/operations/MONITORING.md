# Operations - Monitoring and Observability

Complete monitoring and observability guide for RHIS deployments.

## System Metrics Collection

### Prometheus Configuration

RHIS uses Prometheus for metrics collection:

```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'aap-controller'
    metrics_path: '/api/v2/metrics'
    scheme: https
    static_configs:
      - targets: ['aap.example.com']

  - job_name: 'scenario_satellite'
    static_configs:
      - targets: ['scenario_satellite.example.com:9090']

  - job_name: 'node-exporters'
    static_configs:
      - targets:
          - 'aap.example.com:9100'
          - 'scenario_satellite.example.com:9100'
          - 'idm.example.com:9100'
```

### Enable Metrics Export

On managed systems:

```bash
# Install Node Exporter
sudo yum install -y node_exporter

# Start service
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify metrics endpoint
curl http://localhost:9100/metrics | head -20
```

## Dashboard Access

### Grafana

AAP Grafana dashboard provides visualization:

```
URL: https://aap.example.com:3000
Default Username: admin
Default Password: Check AAP settings
```

**Key Dashboards:**

1. **AAP Overview**
   - Job execution rates
   - Success/failure ratios
   - Capacity utilization

2. **System Health**
   - CPU usage
   - Memory utilization
   - Disk I/O

3. **Database Performance**
   - Query response times
   - Connection count
   - Transaction rate

4. **Satellite Inventory**
   - Registered systems
   - Compliance status
   - Update availability

## Key Metrics to Monitor

### AAP Controller

```
# Job metrics
job_duration_seconds          # Time to execute jobs
job_failure_count             # Failed job executions
job_success_count             # Successful executions
job_queue_depth              # Pending jobs

# System metrics
controller_cpu_usage         # CPU percentage
controller_memory_usage      # Memory consumption
database_connection_count    # Active DB connections
```

### Satellite

```
# Repository metrics
repo_sync_duration           # Time to sync repos
repo_sync_failures           # Failed syncs
repo_size_bytes              # Storage used

# System health
satellite_server_uptime      # Time running
sync_task_status             # Async task health
api_response_time            # API latency
```

### IdM

```
# Authentication metrics
ldap_bind_duration           # Auth response time
krb5_ticket_count            # Active Kerberos tickets
replication_lag              # Multi-node replication delay

# Directory metrics
directory_operations         # Reads/writes per second
connection_count             # Active LDAP connections
```

## Log Aggregation

### Centralized Logging with ELK

Setup Elasticsearch, Logstash, Kibana:

```bash
# Install Elasticsearch
sudo yum install -y elasticsearch

# Install Kibana
sudo yum install -y kibana

# Install Filebeat on each node
sudo yum install -y filebeat

# Configure Filebeat to send logs to Elasticsearch
# /etc/filebeat/filebeat.yml
output.elasticsearch:
  hosts: ["elasticsearch.example.com:9200"]
```

### Configure Log Shipping

**AAP Controller logs:**
```
/var/log/containers/aap-controller-*.log
/var/log/awx/
```

**Satellite logs:**
```
/var/log/foreman/production.log
/var/log/tomcat/catalina.out
/var/log/httpd/
```

**IdM logs:**
```
/var/log/dirsrv/
/var/log/krb5kdc.log
/var/log/kadmind.log
```

## Alert Configuration

### Example Prometheus Alerts

```yaml
# /etc/prometheus/rules/rhis.yml
groups:
  - name: rhis_alerts
    rules:
      - alert: HighMemoryUsage
        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1
        for: 5m
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"

      - alert: JobFailureRate
        expr: job_failure_count > job_success_count
        for: 10m
        annotations:
          summary: "High job failure rate in AAP"

      - alert: DatabaseDown
        expr: up{job="postgresql"} == 0
        for: 1m
        annotations:
          summary: "Database is down"

      - alert: DiskSpaceRunningOut
        expr: node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.1
        for: 5m
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
```

### Alert Routing

Configure Alertmanager for notifications:

```yaml
# /etc/alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m

route:
  receiver: default
  routes:
    - match:
        severity: critical
      receiver: critical_team

receivers:
  - name: default
    email_configs:
      - to: ops@example.com

  - name: critical_team
    slack_configs:
      - api_url: https://hooks.slack.com/services/...
        channel: '#critical-alerts'
```

## Health Checks

### AAP Health Check

```bash
# Check all services
sudo systemctl status awx

# Check connectivity
curl -k https://aap.example.com/api/v2/config/

# Database connectivity
docker exec aap-postgres-1 pg_isready -U awx

# Check container logs for errors
docker logs aap-controller-1 | grep ERROR
```

### Satellite Health Check

```bash
# Check service status
sudo systemctl status foreman foreman-proxy

# Check database
sudo -u postgres pg_isready

# Check Tomcat
sudo systemctl status tomcat

# Check API connectivity
curl -X GET https://scenario_satellite.example.com/api/v2/organizations/
```

### IdM Health Check

```bash
# Check IPA service
sudo ipactl status

# Check LDAP
ldapwhoami -x -h localhost

# Check Kerberos KDC
sudo systemctl status krb5kdc

# Verify replication status
sudo ipa-replica-manage list -r
```

## Performance Tuning

### Database Performance

Monitor query performance:

```sql
-- Find slow queries
SELECT query, calls, mean_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Check index usage
SELECT schemaname, tablename, indexname, idx_scan
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

### Memory Optimization

```bash
# Increase AAP JVM heap
export CONTROLLER_SETTINGS_EXTRA='{"AWX_TASK_ENV":{"PYTHONUNBUFFERED":"1"}}'

# Increase PostgreSQL shared buffers
sudo -u postgres psql -c "ALTER SYSTEM SET shared_buffers='16GB';"
sudo systemctl restart postgresql
```

### Network Optimization

```bash
# Tune TCP parameters
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem="4096 87380 67108864"
sudo sysctl -w net.ipv4.tcp_wmem="4096 65536 67108864"
```

## Capacity Planning

### Monitor Usage Trends

Track metrics over time:

```
Weekly Report
- Jobs executed: 1,500 (↑ 10% vs last week)
- Average job duration: 45 seconds
- Peak concurrent jobs: 25
- Database size: 50 GB (↑ 2 GB/week)

Projections
- At current growth: Database full in 25 weeks
- Peak capacity reached in 12 weeks
```

### Scale Up Planning

- **CPU**: Increase execution nodes
- **Memory**: Add more control nodes or VMs
- **Disk**: Satellite repo mirror capacity
- **Network**: Monitor bandwidth utilization

## Backup Verification

### Test Backup Restoration

```bash
# Backup AAP
sudo docker exec aap-postgres-1 pg_dump -U awx awx > aap-backup.sql

# Restore to test system
sudo docker exec aap-postgres-test-1 psql -U awx awx < aap-backup.sql

# Verify data
sudo docker exec aap-postgres-test-1 psql -U awx awx -c "SELECT COUNT(*) FROM main_job;"
```

## SLA Monitoring

### Key Performance Indicators (KPIs)

```
Availability: 99.9% (target)
Mean Time To Resolution (MTTR): < 1 hour
Mean Time Between Failures (MTBF): > 720 hours
Job Success Rate: > 95%
```

### Monthly Review

```bash
# Generate monthly report
echo "=== AAP Performance Report ==="
echo "Total jobs: $(curl -s https://aap.example.com/api/v2/jobs/ | jq '.count')"
echo "Uptime: $(uptime)"
echo "Database size: $(du -sh /var/lib/pgsql/)"
```

---

See [Troubleshooting](../troubleshooting/) for issue resolution and [Operations](.) for other operations guides.
