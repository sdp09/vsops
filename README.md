# Database Observability Project

A comprehensive monitoring solution for PostgreSQL and Redshift databases using modern observability tools.

## Project Structure

```
vsops/
├── docker-compose-databases.yml           # Database services setup
├── docker-compose-observability.yml       # Complete monitoring stack
├── init-scripts/
│   ├── postgresql/
│   │   ├── 01-schema.sql                  # PostgreSQL schema
│   │   └── 02-data.sql                    # PostgreSQL mock data
│   └── redshift/
│       ├── 01-schema.sql                  # Mock Redshift schema
│       └── 02-data.sql                    # Mock Redshift data
├── prometheus/
│   └── prometheus.yml                     # Prometheus configuration
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasources.yml            # Grafana data sources
│   │   └── dashboards/
│   │       └── dashboards.yml             # Dashboard provisioning
│   └── dashboards/
│       ├── postgresql-dashboard.json      # PostgreSQL dashboard
│       └── redshift-dashboard.json        # Redshift dashboard
└── README.md                              # This file
```

## Services Overview

### Database Services
- **PostgreSQL**: Primary database with observability_db
- **Mock Redshift**: PostgreSQL configured to simulate Redshift

### Monitoring Stack
- **postgres_exporter**: Collects PostgreSQL metrics
- **Victoria Metrics**: Long-term metrics storage
- **Prometheus**: Metrics collection and scraping
- **Grafana**: Visualization and dashboards

## Quick Start

### 1. Start Database Services Only

```bash
# Start just the databases
docker-compose -f docker-compose-databases.yml up -d

# Verify databases are running
docker-compose -f docker-compose-databases.yml ps
```

### 2. Start Complete Observability Stack

```bash
# Start the full monitoring stack (includes databases)
docker-compose -f docker-compose-observability.yml up -d

# Check all services
docker-compose -f docker-compose-observability.yml ps
```

## Service Access

| Service | URL | Credentials |
|---------|-----|-------------|
| PostgreSQL | localhost:5432 | postgres/postgres123 |
| Mock Redshift | localhost:5439 | redshift_user/redshift123 |
| Grafana | http://localhost:3000 | admin/admin123 |
| Prometheus | http://localhost:9090 | - |
| Victoria Metrics | http://localhost:8428 | - |
| PostgreSQL Exporter | http://localhost:9187/metrics | - |
| Redshift Exporter | http://localhost:9188/metrics | - |

## Database Schemas

### PostgreSQL Schema
- **users**: User information with departments and salaries
- **orders**: Order transactions linked to users
- Includes proper indexes and triggers for monitoring

### Mock Redshift Schema
- **users**: Analytics-focused user data
- **user_analytics**: User behavior metrics
- **sales_fact**: Sales transaction data warehouse table
- **product_dim**: Product dimension table

## Grafana Dashboards

### PostgreSQL Dashboard
- Database connection status
- Active connections monitoring
- Database size tracking
- Transaction rates (commits/rollbacks)
- Buffer cache hit ratio
- Table statistics and operations

### Mock Redshift Dashboard
- Data warehouse connection status
- Analytics query performance
- Table scan operations
- Cache efficiency metrics
- Workload monitoring

## Importing Grafana Dashboards

The dashboards are automatically provisioned when you start the services. If you need to manually import:

1. Access Grafana at http://localhost:3000
2. Login with admin/admin123
3. Go to "+" → Import
4. Upload the JSON files from `grafana/dashboards/`
5. Select "VictoriaMetrics" as the data source

## Monitoring Features

### Key Metrics Collected
- **Connection Metrics**: Active connections, connection pools
- **Performance Metrics**: Query execution times, cache hit ratios
- **Resource Metrics**: Database sizes, table statistics
- **Transaction Metrics**: Commits, rollbacks, locks
- **Index Usage**: Sequential vs index scans

### Alerting (Future Enhancement)
The setup is ready for alerting rules. You can add:
- High connection count alerts
- Low cache hit ratio warnings
- Database size growth alerts
- Long-running query notifications

## Troubleshooting

### Common Issues

1. **Services not starting**:
   ```bash
   # Check logs
   docker-compose -f docker-compose-observability.yml logs [service-name]
   
   # Restart specific service
   docker-compose -f docker-compose-observability.yml restart [service-name]
   ```

2. **Database connection issues**:
   ```bash
   # Test PostgreSQL connection
   docker exec -it postgresql_db psql -U postgres -d observability_db -c "SELECT version();"
   
   # Test Mock Redshift connection
   docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "SELECT version();"
   ```

3. **Exporter not collecting metrics**:
   ```bash
   # Check exporter logs
   docker-compose logs postgres-exporter
   docker-compose logs redshift-exporter
   
   # Test metrics endpoint
   curl http://localhost:9187/metrics
   curl http://localhost:9188/metrics
   ```

4. **Grafana dashboard issues**:
   - Verify data sources are configured correctly
   - Check if Victoria Metrics is receiving data
   - Ensure proper time ranges in dashboard queries

### Cleanup

```bash
# Stop all services
docker-compose -f docker-compose-observability.yml down

# Stop and remove volumes (WARNING: This will delete all data)
docker-compose -f docker-compose-observability.yml down -v

# Remove images (optional)
docker-compose -f docker-compose-observability.yml down --rmi all
```

## Customization

### Adding More Databases
1. Add new database service to docker-compose
2. Create new exporter service
3. Update Prometheus scrape configuration
4. Create custom Grafana dashboards

### Custom Metrics
- Modify exporter configurations
- Add custom SQL queries for specific metrics
- Create additional Grafana panels

### Scaling
- Use external PostgreSQL/Redshift instances
- Deploy Victoria Metrics cluster
- Add load balancing for Grafana

## Security Considerations

- Change default passwords in production
- Use secrets management for credentials
- Implement network security policies
- Enable SSL/TLS for database connections
- Set up proper authentication for monitoring services

## Next Steps

1. Set up alerting rules in Prometheus
2. Create custom dashboards for specific use cases
3. Implement log aggregation with ELK stack
4. Add application performance monitoring
5. Set up automated backup monitoring