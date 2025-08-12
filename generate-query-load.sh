#!/bin/bash

# Script to generate query load for testing average execution time metrics
# This simulates different types of queries with varying execution times

echo "Generating query load for Redshift performance testing..."

# PostgreSQL queries (OLTP workload)
echo "=== PostgreSQL Workload ==="
for i in {1..10}; do
    echo "Running PostgreSQL query set $i..."
    
    # Fast queries
    docker exec -it postgresql_db psql -U postgres -d observability_db -c "
    SELECT COUNT(*) FROM users WHERE department = 'Engineering';
    SELECT AVG(salary) FROM users WHERE created_at > NOW() - INTERVAL '30 days';
    SELECT name, email FROM users WHERE id = $((RANDOM % 15 + 1));
    " &
    
    # Medium complexity queries
    docker exec -it postgresql_db psql -U postgres -d observability_db -c "
    SELECT 
        u.department,
        COUNT(*) as user_count,
        AVG(u.salary) as avg_salary,
        COUNT(o.id) as total_orders,
        SUM(o.total_amount) as total_revenue
    FROM users u
    LEFT JOIN orders o ON u.id = o.user_id
    GROUP BY u.department
    ORDER BY total_revenue DESC;
    " &
    
    # Slower analytical queries
    docker exec -it postgresql_db psql -U postgres -d observability_db -c "
    WITH monthly_stats AS (
        SELECT 
            DATE_TRUNC('month', o.order_date) as month,
            u.department,
            COUNT(o.id) as orders,
            SUM(o.total_amount) as revenue
        FROM orders o
        JOIN users u ON o.user_id = u.id
        GROUP BY DATE_TRUNC('month', o.order_date), u.department
    )
    SELECT 
        month,
        department,
        orders,
        revenue,
        LAG(revenue) OVER (PARTITION BY department ORDER BY month) as prev_revenue,
        (revenue - LAG(revenue) OVER (PARTITION BY department ORDER BY month)) / 
        NULLIF(LAG(revenue) OVER (PARTITION BY department ORDER BY month), 0) * 100 as growth_rate
    FROM monthly_stats
    ORDER BY month, department;
    " &
    
    sleep 2
done

wait
echo "PostgreSQL workload completed."

# Mock Redshift queries (Data Warehouse workload)  
echo "=== Mock Redshift Workload ==="
for i in {1..10}; do
    echo "Running Redshift query set $i..."
    
    # Fast aggregations
    docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
    SELECT department, COUNT(*) FROM users GROUP BY department;
    SELECT AVG(page_views) FROM user_analytics WHERE last_login > NOW() - INTERVAL '7 days';
    SELECT region, SUM(total_amount) FROM sales_fact WHERE sale_date >= CURRENT_DATE - 30;
    " &
    
    # Complex analytical queries
    docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
    SELECT 
        u.department,
        AVG(ua.page_views) as avg_page_views,
        AVG(ua.session_duration) as avg_session_time,
        SUM(ua.total_purchases) as total_purchases,
        COUNT(DISTINCT u.id) as unique_users
    FROM users u
    JOIN user_analytics ua ON u.id = ua.user_id
    GROUP BY u.department
    ORDER BY total_purchases DESC;
    " &
    
    # Heavy joins and window functions
    docker exec -it mock_redshift_db psql -U redshift_user -d redshift_db -c "
    WITH user_sales AS (
        SELECT 
            u.id,
            u.name,
            u.department,
            COUNT(sf.id) as total_sales,
            SUM(sf.total_amount) as revenue,
            AVG(sf.total_amount) as avg_order_value
        FROM users u
        LEFT JOIN sales_fact sf ON u.id = sf.user_id
        GROUP BY u.id, u.name, u.department
    ),
    analytics_summary AS (
        SELECT 
            ua.user_id,
            ua.page_views,
            ua.session_duration,
            ua.total_purchases,
            RANK() OVER (ORDER BY ua.page_views DESC) as engagement_rank
        FROM user_analytics ua
    )
    SELECT 
        us.name,
        us.department,
        us.total_sales,
        us.revenue,
        us.avg_order_value,
        als.page_views,
        als.engagement_rank,
        CASE 
            WHEN als.engagement_rank <= 3 THEN 'High'
            WHEN als.engagement_rank <= 7 THEN 'Medium'
            ELSE 'Low'
        END as engagement_category
    FROM user_sales us
    JOIN analytics_summary als ON us.id = als.user_id
    ORDER BY us.revenue DESC, als.engagement_rank;
    " &
    
    sleep 3
done

wait
echo "Mock Redshift workload completed."

echo "All query load generation completed!"
echo "You can now check the metrics in Grafana or query them directly:"
echo "curl 'http://localhost:8428/api/v1/query?query=pg_stat_activity_count'"