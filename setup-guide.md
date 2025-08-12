# Setup Guide - Database Observability Project

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Ports 3000, 5432, 5439, 8428, 9090, 9187, 9188 available

## Step-by-Step Setup

### Step 1: Clone and Prepare

```bash
# Navigate to your project directory
cd /path/to/your/project

# Ensure all directories exist
mkdir -p init-scripts/postgresql init-scripts/redshift
mkdir -p prometheus grafana/provisioning/datasources grafana/provisioning/dashboards grafana/dashboards
```

### Step 2: Database-Only Setup (Optional)

If you want to start with just the databases:

```bash
# Start databases only
docker-compose -f docker-compose-databases.yml up -d

# Wait for databases to be ready (check health)
docker-compose -f docker-compose-databases.yml ps

# Test connections
docker exec -it postgresql_db psql -U postgres -d observability_db -c "SELECT COUNT(*) FROM users;"
docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "SELECT COUNT(*) FROM users;"
```

Expected output should show 15 users in PostgreSQL and 10 users in Mock Redshift.

### Step 3: Full Observability Stack

```bash
# Start the complete monitoring stack
docker-compose -f docker-compose-observability.yml up -d

# Monitor startup (this may take 2-3 minutes)
docker-compose -f docker-compose-observability.yml logs -f
```

### Step 4: Verify Services

Check that all services are running:

```bash
docker-compose -f docker-compose-observability.yml ps
```

Expected status: All services should show "Up" status.

### Step 5: Access Grafana

1. Open browser to http://localhost:3000
2. Login with:
   - Username: `admin`
   - Password: `admin123`
3. Navigate to "Dashboards" → "Browse"
4. You should see two dashboards:
   - PostgreSQL Database Monitoring
   - Mock Redshift Data Warehouse Monitoring

### Step 6: Verify Data Sources

1. In Grafana, go to "Configuration" → "Data Sources"
2. Verify "VictoriaMetrics" is configured and working
3. Click "Test" to ensure connection is successful

### Step 7: Validate Dashboards

#### PostgreSQL Dashboard
1. Open "PostgreSQL Database Monitoring" dashboard
2. Verify you see:
   - Database Status: "UP" (green)
   - Active Connections: Should show connection count
   - Database Size: Should show size in bytes
   - Transaction Rate: Should show some activity

#### Mock Redshift Dashboard
1. Open "Mock Redshift Data Warehouse Monitoring" dashboard
2. Verify you see:
   - Mock Redshift Status: "UP" (green)
   - Data Warehouse Connections: Should show connection count
   - Data Warehouse Size: Should show size in bytes

### Step 8: Generate Test Activity

To see more interesting metrics, generate some database activity:

```bash
# PostgreSQL test queries
docker exec -it postgresql_db psql -U postgres -d observability_db -c "
SELECT u.name, COUNT(o.id) as order_count, SUM(o.total_amount) as total_spent
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
ORDER BY total_spent DESC;
"

# Mock Redshift test queries
docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
SELECT 
    u.name,
    u.department,
    ua.page_views,
    ua.total_purchases,
    COUNT(sf.id) as sales_count
FROM users u
JOIN user_analytics ua ON u.id = ua.user_id
LEFT JOIN sales_fact sf ON u.id = sf.user_id
GROUP BY u.id, u.name, u.department, ua.page_views, ua.total_purchases
ORDER BY ua.total_purchases DESC;
"
```

After running these queries, you should see increased activity in your dashboards.

## Troubleshooting Common Issues

### Issue 1: Services Not Starting

**Symptoms**: Some containers exit immediately or show errors

**Solutions**:
```bash
# Check logs for specific service
docker-compose -f docker-compose-observability.yml logs [service-name]

# Common fixes:
# 1. Check port availability
netstat -tlnp | grep -E '(3000|5432|5439|8428|9090|9187|9188)'

# 2. Restart specific service
docker-compose -f docker-compose-observability.yml restart [service-name]

# 3. Rebuild if needed
docker-compose -f docker-compose-observability.yml up --build -d
```

### Issue 2: Database Connection Failures

**Symptoms**: Exporters can't connect to databases

**Solutions**:
```bash
# Check database health
docker-compose -f docker-compose-observability.yml exec postgresql_db pg_isready -U postgres
docker-compose -f docker-compose-observability.yml exec mock_redshift_db pg_isready -U redshift_user

# Check network connectivity
docker network ls
docker network inspect vsops_db_network
docker network inspect vsops_monitoring_network
```

### Issue 3: No Metrics in Grafana

**Symptoms**: Dashboards show "No data" or empty panels

**Solutions**:
```bash
# 1. Check if exporters are working
curl http://localhost:9187/metrics | head -20
curl http://localhost:9188/metrics | head -20

# 2. Check Prometheus targets
# Open http://localhost:9090/targets

# 3. Check Victoria Metrics
curl http://localhost:8428/api/v1/label/__name__/values | jq .

# 4. Verify data source in Grafana
# Configuration → Data Sources → VictoriaMetrics → Test
```

### Issue 4: Permission Issues

**Symptoms**: Volume mounting errors or file permission issues

**Solutions**:
```bash
# Fix permissions
chmod -R 755 grafana/
chmod -R 755 prometheus/
chmod -R 755 init-scripts/

# If using Linux, you might need:
sudo chown -R 472:472 grafana/  # Grafana user ID
```

### Issue 5: Memory Issues

**Symptoms**: Services are killed or run out of memory

**Solutions**:
```bash
# Check container resource usage
docker stats

# Increase Docker memory if needed (Docker Desktop settings)
# Or add resource limits to docker-compose:
# deploy:
#   resources:
#     limits:
#       memory: 512M
```

## Verification Checklist

Use this checklist to ensure everything is working:

- [ ] All containers are running (`docker-compose ps`)
- [ ] PostgreSQL accessible on port 5432
- [ ] Mock Redshift accessible on port 5439
- [ ] Grafana accessible at http://localhost:3000
- [ ] Prometheus accessible at http://localhost:9090
- [ ] Victoria Metrics accessible at http://localhost:8428
- [ ] Exporters returning metrics on ports 9187 and 9188
- [ ] Grafana data source test successful
- [ ] PostgreSQL dashboard showing data
- [ ] Mock Redshift dashboard showing data
- [ ] Test queries return expected results

## Performance Tuning

### For Development
Default configuration is optimized for development with minimal resource usage.

### For Production
Consider these adjustments:

1. **Victoria Metrics**:
   - Increase retention period: `--retentionPeriod=90d`
   - Adjust memory settings: `--memory.allowedPercent=80`

2. **Prometheus**:
   - Increase scrape intervals for less critical metrics
   - Add alerting rules

3. **Grafana**:
   - Enable HTTPS
   - Set up proper authentication
   - Configure email notifications

4. **Databases**:
   - Use persistent volumes in production
   - Implement proper backup strategies
   - Configure connection pooling

## Next Steps

1. **Custom Dashboards**: Create dashboards specific to your use case
2. **Alerting**: Set up Prometheus alerting rules
3. **Security**: Implement proper authentication and encryption
4. **Scaling**: Consider cluster setups for production workloads
5. **Integration**: Connect to your actual databases instead of mock services

## Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review container logs: `docker-compose logs [service-name]`
3. Verify network connectivity between services
4. Ensure all required ports are available
5. Check Docker resources (CPU, memory, disk space)