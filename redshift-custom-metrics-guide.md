# Redshift Custom Metrics Guide - Query Execution Times

This guide shows how to collect and monitor custom metrics for Redshift, specifically focusing on **average query execution time** and other performance metrics.

## Available Query Performance Metrics

### 1. Query Execution Time Metrics

**Key Metrics Already Available:**
- `pg_stat_activity_max_tx_duration` - Maximum transaction/query duration per connection
- `pg_stat_activity_count` - Number of connections by state (active, idle, etc.)
- `pg_stat_database_xact_commit_total` - Transaction commit rate
- `pg_stat_database_tup_returned_total` - Rows returned rate

### 2. Custom Dashboard for Query Performance

I've created a specialized dashboard: **`redshift-query-performance.json`**

**Dashboard Panels:**
1. **Query Execution Time** - Shows max and average query duration
2. **Connection States** - Active vs idle connections 
3. **Longest Running Query** - Current slowest query
4. **Active Query Count** - Number of currently running queries
5. **Query Activity Percentage** - Percentage of active vs total connections
6. **Database Transaction Rate** - Commits, rollbacks, and rows returned per second
7. **Table Scan Performance** - Sequential vs index scans

## How to Get Average Query Execution Time

### Method 1: Using Built-in Metrics (Recommended)

The postgres_exporter already provides query execution time metrics:

```promql
# Average query execution time across all active connections
avg(pg_stat_activity_max_tx_duration{job="redshift-exporter", datname="redshift_db", state="active"})

# Maximum query execution time 
max(pg_stat_activity_max_tx_duration{job="redshift-exporter", datname="redshift_db"})

# Query execution time by user
pg_stat_activity_max_tx_duration{job="redshift-exporter", datname="redshift_db", usename!=""}
```

### Method 2: Generating Test Workload

Use the provided script to generate realistic query patterns:

```bash
# Run the query load generator
./generate-query-load.sh

# Or run specific test queries manually:
docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
WITH user_sales AS (
    SELECT 
        u.id, u.name, u.department,
        COUNT(sf.id) as total_sales,
        SUM(sf.total_amount) as revenue,
        AVG(sf.total_amount) as avg_order_value
    FROM users u
    LEFT JOIN sales_fact sf ON u.id = sf.user_id
    GROUP BY u.id, u.name, u.department
)
SELECT 
    name, department, total_sales, revenue, avg_order_value
FROM user_sales
ORDER BY revenue DESC;
"
```

### Method 3: Custom Queries via API

Query metrics directly from Victoria Metrics:

```bash
# Get current average query execution time
curl -s "http://localhost:8428/api/v1/query?query=avg(pg_stat_activity_max_tx_duration{job=\"redshift-exporter\"})"

# Get query execution time over time (5-minute average)
curl -s "http://localhost:8428/api/v1/query_range?query=avg(pg_stat_activity_max_tx_duration{job=\"redshift-exporter\"})&start=$(date -d '1 hour ago' +%s)&end=$(date +%s)&step=300"
```

## Setting Up the Query Performance Dashboard

### Step 1: Import Dashboard in Grafana

1. Go to http://localhost:3000
2. Navigate to **Dashboards** → **Import**
3. Upload `grafana/dashboards/redshift-query-performance.json`
4. Select **VictoriaMetrics** as the data source
5. Click **Import**

### Step 2: Generate Query Load

Run the load generator to see metrics in action:

```bash
chmod +x generate-query-load.sh
./generate-query-load.sh
```

### Step 3: Monitor Real-time Performance

The dashboard will show:
- **Real-time query execution times**
- **Connection state changes**
- **Query activity patterns**
- **Database throughput metrics**

## Advanced Custom Metrics Configuration

### Current Configuration Status

✅ **Exporters configured** with stat_statements collector enabled
✅ **Custom query files** created for advanced metrics  
✅ **Dashboard panels** ready for query performance data
✅ **Load generation script** available for testing

### Key Prometheus Queries for Redshift Performance

```promql
# Average query execution time (last 5 minutes)
avg_over_time(pg_stat_activity_max_tx_duration{job="redshift-exporter", datname="redshift_db"}[5m])

# Query throughput (queries per second)
rate(pg_stat_database_xact_commit_total{job="redshift-exporter", datname="redshift_db"}[5m])

# Slow query detection (queries > 30 seconds)
pg_stat_activity_max_tx_duration{job="redshift-exporter", datname="redshift_db"} > 30

# Connection utilization
sum(pg_stat_activity_count{job="redshift-exporter", datname="redshift_db", state="active"}) / 
sum(pg_stat_activity_count{job="redshift-exporter", datname="redshift_db"}) * 100

# Table scan efficiency 
pg_stat_user_tables_idx_scan{job="redshift-exporter"} / 
(pg_stat_user_tables_idx_scan{job="redshift-exporter"} + pg_stat_user_tables_seq_scan{job="redshift-exporter"})
```

## Real Redshift Integration

To use this setup with **actual Amazon Redshift**:

### 1. Update Connection String

```yaml
# In docker-compose-observability.yml
environment:
  DATA_SOURCE_NAME: "postgresql://username:password@redshift-cluster.region.redshift.amazonaws.com:5439/database_name?sslmode=require"
```

### 2. Enable Required Extensions

In your Redshift cluster, enable query monitoring:
- Configure query monitoring rules (QMR)
- Enable CloudWatch metrics
- Set up performance insights

### 3. Redshift-Specific Metrics

For real Redshift, you can also query:
- `STL_QUERY` - Query execution details
- `SVL_QUERY_SUMMARY` - Query performance summary  
- `STL_WLM_QUERY` - Workload management stats
- `SVV_QUERY_INFLIGHT` - Currently running queries

## Alerting Examples

Set up alerts for query performance issues:

```yaml
# In Prometheus alerting rules
groups:
  - name: redshift_performance
    rules:
      - alert: SlowQueryDetected
        expr: pg_stat_activity_max_tx_duration{job="redshift-exporter"} > 300
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Slow query detected in Redshift"
          description: "Query running for {{ $value }}s on {{ $labels.datname }}"
      
      - alert: HighQueryLoad  
        expr: sum(pg_stat_activity_count{job="redshift-exporter", state="active"}) > 20
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "High number of concurrent queries"
          description: "{{ $value }} active queries detected"
```

## Next Steps

1. **Import the query performance dashboard**
2. **Run the load generator** to see metrics in action
3. **Customize queries** for your specific use case
4. **Set up alerting** for performance thresholds
5. **Integrate with real Redshift** when ready

The setup provides comprehensive query execution time monitoring and can be extended with additional custom metrics as needed!