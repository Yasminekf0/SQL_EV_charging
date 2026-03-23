-- 1. sessions and kWh per station
SELECT
    st.name,
    st.location,
    COUNT(se.session_id)  AS total_sessions,
    AVG(se.kwh_delivered) AS avg_kwh,
    SUM(se.kwh_delivered) AS total_kwh
FROM stations st
LEFT JOIN sessions se ON st.station_id = se.station_id
GROUP BY st.station_id, st.name, st.location
ORDER BY total_sessions DESC;


-- 2. top 5 users by total charge time
SELECT user_rank, full_name, total_sessions, total_minutes_charging
FROM (
    SELECT
        u.full_name,
        COUNT(se.session_id) AS total_sessions,
        SUM(DATEDIFF('minute', se.started_at, se.ended_at)) AS total_minutes_charging,
        DENSE_RANK() OVER (ORDER BY SUM(DATEDIFF('minute', se.started_at, se.ended_at)) DESC) AS user_rank
    FROM users u
    JOIN sessions se ON u.user_id = se.user_id
    GROUP BY u.user_id, u.full_name
) ranked
WHERE user_rank <= 5;


-- 3. stations below network average (find underperforming stations)
WITH station_counts AS (
    SELECT st.station_id, st.name, st.location, COUNT(se.session_id) AS session_count
    FROM stations st
    LEFT JOIN sessions se ON st.station_id = se.station_id
    GROUP BY st.station_id, st.name, st.location
),
network_avg AS (
    SELECT AVG(session_count) AS avg_sessions FROM station_counts
)
SELECT sc.name, sc.location, sc.session_count, ROUND(na.avg_sessions, 1) AS network_average
FROM station_counts sc
JOIN network_avg na ON 1=1
WHERE sc.session_count < na.avg_sessions
ORDER BY sc.session_count ASC;


-- 4. sessions per month and growth vs previous month
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', started_at) AS month,
        COUNT(session_id) AS sessions
    FROM sessions
    GROUP BY DATE_TRUNC('month', started_at)
)
SELECT
    TO_CHAR(month, 'YYYY-MM') AS month,
    sessions,
    sessions - LAG(sessions) OVER (ORDER BY month) AS sessions_vs_prev_month
FROM monthly
ORDER BY month;


-- 5. users who have used more than one station
SELECT
    u.full_name,
    u.email,
    COUNT(DISTINCT se.station_id) AS stations_used,
    COUNT(se.session_id)          AS total_sessions
FROM users u
JOIN sessions se ON u.user_id = se.user_id
GROUP BY u.user_id, u.full_name, u.email
HAVING COUNT(DISTINCT se.station_id) > 1
ORDER BY stations_used DESC, total_sessions DESC;
