# Manual Grafana Setup Guide

## Issue Resolution Summary

The automatic provisioning was causing restart loops due to plugin signature issues and data source conflicts. Grafana is now running with a clean configuration and requires manual setup.

## Current Status ✅

- **All monitoring services**: Running
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Victoria Metrics**: Collecting data from Prometheus
- **Prometheus**: Scraping both database exporters
- **Database exporters**: Connected and collecting metrics

## Manual Data Source Setup

### Step 1: Add Victoria Metrics Data Source

1. Go to http://localhost:3000
2. Login with **admin** / **admin123**
3. Navigate to **Configuration** → **Data Sources**
4. Click **Add data source**
5. Select **Prometheus**
6. Configure:
   - **Name**: `VictoriaMetrics`
   - **URL**: `http://victoria-metrics:8428`
   - **Access**: Server (default)
   - Leave other settings as default
7. Click **Save & Test** - should show green "Data source is working"

### Step 2: Add Prometheus Data Source (Optional)

1. Click **Add data source** again
2. Select **Prometheus**
3. Configure:
   - **Name**: `Prometheus`
   - **URL**: `http://prometheus:9090`
   - **Access**: Server (default)
4. Click **Save & Test**

### Step 3: Import Dashboard - PostgreSQL

1. Go to **Dashboards** → **Import**
2. Click **Upload JSON file**
3. Select `/path/to/vsops/grafana/dashboards/postgresql-dashboard.json`
4. On import screen:
   - **Name**: PostgreSQL Database Monitoring
   - **Data source**: Select **VictoriaMetrics**
5. Click **Import**

### Step 4: Import Dashboard - Redshift

1. Go to **Dashboards** → **Import**
2. Click **Upload JSON file**
3. Select `/path/to/vsops/grafana/dashboards/redshift-dashboard.json`
4. On import screen:
   - **Name**: Mock Redshift Data Warehouse Monitoring
   - **Data source**: Select **VictoriaMetrics**
5. Click **Import**

## Verification Steps

### Test Data Source Connection

In Grafana, go to **Explore** and run these queries:

1. **Test basic connectivity**:
   ```
   pg_up
   ```
   Should return `1` for both exporters

2. **Test PostgreSQL metrics**:
   ```
   pg_stat_database_xact_commit_total{datname="observability_db"}
   ```

3. **Test Redshift metrics**:
   ```
   pg_stat_database_xact_commit_total{datname="redshift_db"}
   ```

### Generate Test Activity

Run these commands to create database activity:

```bash
# PostgreSQL test
docker exec -it postgresql_db psql -U postgres -d observability_db -c "
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM orders;
SELECT u.name, COUNT(o.id) as orders FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.name LIMIT 5;
"

# Mock Redshift test
docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM sales_fact;
SELECT department, COUNT(*) FROM users GROUP BY department;
"
```

### Expected Dashboard Data

**PostgreSQL Dashboard should show**:
- Database Status: UP (green)
- Active Connections: 1-5 connections
- Database Size: ~8-12 MB
- Transaction Rate: Some activity after running test queries
- Buffer Cache Hit Ratio: >95%
- Table Statistics: Row counts for users/orders tables

**Redshift Dashboard should show**:
- Mock Redshift Status: UP (green)
- Data Warehouse Connections: 1-3 connections
- Data Warehouse Size: ~8-15 MB
- Analytics Query Rate: Activity from test queries
- Table Scans: Statistics for analytics tables

## Troubleshooting

### No Data in Panels

1. **Check data source**: Go to data source settings and click "Save & Test"
2. **Check time range**: Use "Last 5 minutes" or "Last 1 hour"
3. **Refresh dashboard**: Click refresh button or Ctrl+R

### Connection Issues

```bash
# Test if services can reach each other
docker exec grafana curl -s http://victoria-metrics:8428/api/v1/query?query=up
docker exec grafana curl -s http://prometheus:9090/api/v1/query?query=up
```

### Restart Services if Needed

```bash
# Restart individual services
docker-compose -f docker-compose-observability.yml restart victoria-metrics
docker-compose -f docker-compose-observability.yml restart prometheus
docker-compose -f docker-compose-observability.yml restart grafana
```

## Next Steps After Setup

1. **Create custom dashboards** for your specific monitoring needs
2. **Set up alerting rules** in Prometheus
3. **Configure notification channels** in Grafana
4. **Add more database instances** to monitor production systems
5. **Implement log aggregation** for comprehensive observability

## Quick Commands Reference

```bash
# Check all services status
docker-compose -f docker-compose-observability.yml ps

# View metrics endpoints
curl http://localhost:9187/metrics | grep pg_up  # PostgreSQL
curl http://localhost:9188/metrics | grep pg_up  # Redshift

# Query Victoria Metrics directly
curl "http://localhost:8428/api/v1/query?query=pg_up"

# Access services
# Grafana: http://localhost:3000 (admin/admin123)
# Prometheus: http://localhost:9090
# Victoria Metrics: http://localhost:8428
```

The monitoring stack is now fully functional and ready for manual configuration!