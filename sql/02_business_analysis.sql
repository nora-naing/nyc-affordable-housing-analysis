-- Project	: MySQL - NYC's Affordable Housing Production
-- File		: 02_business_analysis.sql
-- Author	: Nora Thu Thu Htet Naing
-- Purpose	: Analyze affordable housing patterns, project concentration, affordability,
--            construction strategy, and housing composition to support business insights.

USE affordable_housing;

-- 01 Geographic Distribution

-- 1.1 Borough contribution and ranking
-- Business Question: Which NYC boroughs contribute the most affordable housing?
WITH borough_summary AS (
	SELECT
		borough,
		COUNT(*) AS records,
		SUM(all_counted_units) AS total_affordable_units
	FROM housing_projects
	GROUP BY borough
)
SELECT
	borough,
    records,
    total_affordable_units,
    ROUND(total_affordable_units * 100.0 / SUM(total_affordable_units) OVER(), 2) AS affordable_unit_share_pct,
    DENSE_RANK() OVER(ORDER BY total_affordable_units DESC) AS rank_num
FROM borough_summary
ORDER BY rank_num;


-- 02 Construction Strategy

-- 2.1 Construction strategy contribution
-- Business Question: How much affordable housing does each construction strategy contribute?
WITH construction_summary AS (
    SELECT
        reporting_construction_type,
        COUNT(*) AS records,
        SUM(all_counted_units) AS total_affordable_units
    FROM housing_projects
    GROUP BY reporting_construction_type
)
SELECT
    reporting_construction_type,
    records,
    total_affordable_units,
    ROUND(total_affordable_units * 100.0 / SUM(total_affordable_units) OVER (), 2) AS affordable_unit_share_pct,
    DENSE_RANK() OVER (ORDER BY total_affordable_units DESC) AS rank_num
FROM construction_summary
ORDER BY rank_num;

-- 2.2 Project scale by construction strategy
-- Business Question: How large are project–construction strategy combinations within Preservation vs New Construction?
WITH project_summary AS (
    SELECT
        project_id,
        reporting_construction_type,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    GROUP BY
        project_id,
        reporting_construction_type
)
SELECT
    reporting_construction_type,
    COUNT(*) AS projects,
    SUM(affordable_units) AS total_affordable_units,
    ROUND(AVG(affordable_units), 2) AS avg_affordable_units_per_project,
    MAX(affordable_units) AS largest_project_affordable_units
FROM project_summary
GROUP BY reporting_construction_type
ORDER BY avg_affordable_units_per_project DESC;

-- 2.3 Borough and construction strategy contribution
-- Business Question: Which boroughs rely most heavily on Preservation versus New Construction for affordable housing?
WITH borough_construction AS (
    SELECT
        borough,
        reporting_construction_type,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    GROUP BY
        borough,
        reporting_construction_type
)
SELECT
    borough,
    reporting_construction_type,
    affordable_units,
    ROUND(affordable_units * 100.0 / SUM(affordable_units) OVER (PARTITION BY borough), 2) AS borough_strategy_share_pct
FROM borough_construction
ORDER BY
    borough,
    affordable_units DESC;


-- 03 Income Affordability

-- 3.1 Deep affordability by construction strategy
-- Business Question: Does Preservation or New Construction provide a greater share of Extremely Low + Very Low Income households?
SELECT
    reporting_construction_type,
    SUM(extremely_low_income_units) AS extremely_low_income_units,
    SUM(very_low_income_units) AS very_low_income_units,
    SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units,
    SUM(all_counted_units) AS total_affordable_units,
    ROUND(
        SUM(extremely_low_income_units + very_low_income_units) * 100.0
        / NULLIF(SUM(all_counted_units), 0),
        2
    ) AS deep_affordability_share_pct
FROM housing_projects
GROUP BY reporting_construction_type
ORDER BY deep_affordability_share_pct DESC;

-- 3.2 Deep affordability by borough
-- Business Question: Which boroughs have the strongest concentration of housing serving Extremely Low and Very Low Income households?
SELECT
    borough,
    SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units,
    SUM(all_counted_units) AS total_affordable_units,
    ROUND(
        SUM(extremely_low_income_units + very_low_income_units) * 100.0
        / NULLIF(SUM(all_counted_units), 0),
        2
    ) AS deep_affordability_share_pct,
    DENSE_RANK() OVER (
        ORDER BY
            SUM(extremely_low_income_units + very_low_income_units)
            / NULLIF(SUM(all_counted_units), 0) DESC
    ) AS affordability_rank
FROM housing_projects
GROUP BY borough
ORDER BY affordability_rank;

-- 3.3 Project affordability segmentation
-- Business Question: Which projects are primarily focused on deeply affordable housing versus broader income groups?
WITH project_affordability AS (
    SELECT
        project_id,
        SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units,
        SUM(all_counted_units) AS total_affordable_units,
        ROUND (
			SUM(extremely_low_income_units + very_low_income_units) * 100.0
            / NULLIF(SUM(all_counted_units), 0),
            2
		) AS deep_affordability_share_pct
    FROM housing_projects
    GROUP BY project_id
),
project_segments AS (
    SELECT
        project_id,
        deep_affordable_units,
        total_affordable_units,
        CASE
            WHEN deep_affordability_share_pct >= 50 THEN 'Deep Affordability Focus'
            WHEN deep_affordability_share_pct >= 25 THEN 'Moderate Deep Affordability'
            ELSE 'Lower Deep Affordability'
        END AS affordability_segment
    FROM project_affordability
)
SELECT
    affordability_segment,
    COUNT(*) AS projects,
    SUM(deep_affordable_units) AS deep_affordable_units,
    SUM(total_affordable_units) AS total_affordable_units,
    ROUND(
        SUM(deep_affordable_units) * 100.0
        / NULLIF(SUM(total_affordable_units), 0),
        2
    ) AS deep_affordability_share_pct
FROM project_segments
GROUP BY affordability_segment
ORDER BY deep_affordability_share_pct DESC;


-- 04 Project Scale & Concentration

-- 4.1 Top projects by affordable-unit contribution
-- Business Question: Which projects contribute the most affordable units,
-- and how much of the overall affordable housing supply do they represent?
WITH project_summary AS (
    SELECT
        project_id,
        MAX(project_name) AS project_name,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    GROUP BY project_id
),
project_contribution AS (
    SELECT
        project_id,
        project_name,
        affordable_units,
        ROUND(affordable_units * 100.0 / SUM(affordable_units) OVER (), 2) AS contribution_pct,
        ROUND(
			SUM(affordable_units) OVER (
                ORDER BY affordable_units DESC, project_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) * 100.0
            / SUM(affordable_units) OVER (),
            2
        ) AS cumulative_contribution_pct,
        ROW_NUMBER() OVER (ORDER BY affordable_units DESC, project_id) AS project_rank
    FROM project_summary
)
SELECT
    project_rank,
    project_id,
    project_name,
    affordable_units,
    contribution_pct,
    cumulative_contribution_pct
FROM project_contribution
ORDER BY project_rank;

-- 4.2 Project concentration tiers
-- Business Question: Is affordable housing supply broadly distributed
-- across projects, or concentrated in a small number of very large projects?
WITH project_summary AS (
    SELECT
        project_id,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    GROUP BY project_id
),
project_tiers AS (
    SELECT
        project_id,
        affordable_units,
        CASE
            WHEN affordable_units >= 500 THEN 'Very Large'
            WHEN affordable_units >= 100 THEN 'Large'
            WHEN affordable_units >= 25 THEN 'Medium'
            ELSE 'Small'
        END AS project_size_tier
    FROM project_summary
)
SELECT
    project_size_tier,
    COUNT(*) AS projects,
    SUM(affordable_units) AS total_affordable_units,
    ROUND(SUM(affordable_units) * 100.0 / SUM(SUM(affordable_units)) OVER (), 2) AS affordable_unit_share_pct
FROM project_tiers
GROUP BY project_size_tier
ORDER BY
    CASE project_size_tier
		WHEN 'Very Large' THEN 1
        WHEN 'Large' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Small' THEN 4
	END;


-- 05 Housing Unit Composition

-- 5.1 Rental vs Homeownership by Construction Strategy
-- Business Question: Does Preservation or New Construction have a different rental and homeownership profile?
SELECT
	reporting_construction_type,
	SUM(counted_rental_units) AS total_rental_units,
    SUM(counted_homeownership_units) AS total_homeownership_units,
    SUM(all_counted_units) AS total_affordable_units,
    ROUND(SUM(counted_rental_units) * 100.0 / NULLIF(SUM(all_counted_units), 0), 2) AS rental_share_pct,
    ROUND(SUM(counted_homeownership_units) * 100.0 / NULLIF(SUM(all_counted_units), 0), 2) AS homeownership_share_pct
FROM housing_projects
GROUP BY reporting_construction_type
ORDER BY rental_share_pct DESC;

-- 5.2 Rental vs Homeownership by Borough
-- Business Question: Which boroughs have the strongest rental versus homeownership orientation in their affordable housing supply?
SELECT
	borough,
	SUM(counted_rental_units) AS total_rental_units,
    SUM(counted_homeownership_units) AS total_homeownership_units,
    SUM(all_counted_units) AS total_affordable_units,
    ROUND(SUM(counted_rental_units) * 100.0 / NULLIF(SUM(all_counted_units), 0), 2) AS rental_share_pct,
    ROUND(SUM(counted_homeownership_units) * 100.0 / NULLIF(SUM(all_counted_units), 0), 2) AS homeownership_share_pct
FROM housing_projects
GROUP BY borough
ORDER BY rental_share_pct DESC;

-- 5.3 Affordable vs Market-Rate Composition by Project
-- Business Question: Across all projects, how much of the represented housing is affordable versus market-rate?
WITH project_summary AS (
    SELECT
        project_id,
        SUM(all_counted_units) AS affordable_units,
        SUM(total_units) AS total_units
    FROM housing_projects
    GROUP BY project_id
)
SELECT
    COUNT(*) AS projects,
    SUM(affordable_units) AS total_affordable_units,
    SUM(total_units - affordable_units) AS total_market_rate_units,
    SUM(total_units) AS total_units,
    ROUND(SUM(affordable_units) * 100.0 / NULLIF(SUM(total_units), 0), 2) AS affordable_share_pct,
    ROUND(SUM(total_units - affordable_units) * 100.0 / NULLIF(SUM(total_units), 0), 2) AS market_rate_share_pct
FROM project_summary;


-- 06 Project Duration & Completion

-- 6.1 Completion rate by construction strategy
-- Business Question: Which construction strategy has a higher completion rate?
SELECT
    reporting_construction_type,
    COUNT(*) AS records,
    SUM(CASE
            WHEN project_completion_date IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS completed_records,
    ROUND(
        SUM(CASE
                WHEN project_completion_date IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS completion_rate_pct
FROM housing_projects
GROUP BY reporting_construction_type
ORDER BY completion_rate_pct DESC;

-- 6.2 Completion rate by project start year
-- Business Question: How has project completion status varied across project start years?
SELECT
    YEAR(project_start_date) AS project_start_year,
    COUNT(*) AS records,
    SUM(CASE
            WHEN project_completion_date IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS completed_records,
    ROUND(
        SUM(CASE
                WHEN project_completion_date IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0
        / COUNT(*),
        2
    ) AS completion_rate_pct
FROM housing_projects
WHERE project_start_date IS NOT NULL
GROUP BY YEAR(project_start_date)
ORDER BY project_start_year;


-- 07 Time Trends

-- 7.1 Year-over-year change in affordable housing production
-- Business Question: How has affordable housing production changed from year to year?
-- Note: 2026 is excluded because it represents a partial year.
WITH yearly_production AS (
    SELECT
        YEAR(project_start_date) AS project_start_year,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    WHERE project_start_date IS NOT NULL
      AND YEAR(project_start_date) < 2026
    GROUP BY YEAR(project_start_date)
),
yearly_change AS (
    SELECT
        project_start_year,
        affordable_units,
        LAG(affordable_units) OVER (ORDER BY project_start_year) AS previous_year_affordable_units
    FROM yearly_production
)
SELECT
    project_start_year,
    affordable_units,
    previous_year_affordable_units,
    affordable_units - previous_year_affordable_units AS yoy_change_units,
    ROUND(
        (affordable_units - previous_year_affordable_units) * 100.0
        / NULLIF(previous_year_affordable_units, 0),
        2
    ) AS yoy_change_pct
FROM yearly_change
ORDER BY project_start_year;

-- 7.2 Construction strategy mix over time
-- Business Question: Has the balance between Preservation and New Construction changed over time?
WITH yearly_strategy AS (
    SELECT
        YEAR(project_start_date) AS project_start_year,
        reporting_construction_type,
        SUM(all_counted_units) AS affordable_units
    FROM housing_projects
    WHERE project_start_date IS NOT NULL
    GROUP BY
        YEAR(project_start_date),
        reporting_construction_type
)
SELECT
    project_start_year,
    reporting_construction_type,
    affordable_units,
    ROUND(affordable_units * 100.0 / SUM(affordable_units) OVER (PARTITION BY project_start_year),
		2) AS annual_strategy_share_pct
FROM yearly_strategy
ORDER BY
    project_start_year,
    affordable_units DESC;


-- 08 Advanced Analysis

-- 8.1 Large projects with strong deep affordability
-- Business Question: Which projects combine substantial affordable housing capacity with a strong focus on the lowest-income households?
WITH project_summary AS (
    SELECT
        project_id,
        MAX(project_name) AS project_name,
        SUM(all_counted_units) AS affordable_units,
        SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units
    FROM housing_projects
    GROUP BY project_id
),
project_metrics AS (
    SELECT
        project_id,
        project_name,
        affordable_units,
        deep_affordable_units,
        ROUND(deep_affordable_units * 100.0 / NULLIF(affordable_units, 0), 2) AS deep_affordability_share_pct,
        NTILE(4) OVER (ORDER BY affordable_units) AS size_quartile,
        NTILE(4) OVER (ORDER BY deep_affordable_units * 100.0 / NULLIF(affordable_units, 0)) AS affordability_quartile
    FROM project_summary
)
SELECT
    project_id,
    project_name,
    affordable_units,
    deep_affordable_units,
    deep_affordability_share_pct,
    size_quartile,
    affordability_quartile
FROM project_metrics
WHERE size_quartile = 4
  AND affordability_quartile = 4
ORDER BY
    affordable_units DESC,
    deep_affordability_share_pct DESC;

-- 8.2 Deep-affordability concentration
-- Business Question: How concentrated are the lowest-income housing units among NYC's projects?
WITH project_summary AS (
    SELECT
        project_id,
        MAX(project_name) AS project_name,
        SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units
    FROM housing_projects
    GROUP BY project_id
),
project_contribution AS (
    SELECT
        project_id,
        project_name,
        deep_affordable_units,
        ROUND(deep_affordable_units * 100.0 / SUM(deep_affordable_units) OVER (), 2) AS contribution_pct,
        ROUND(
            SUM(deep_affordable_units) OVER (
                ORDER BY deep_affordable_units DESC, project_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) * 100.0
            / SUM(deep_affordable_units) OVER (),
            2
        ) AS cumulative_contribution_pct,
        ROW_NUMBER() OVER (ORDER BY deep_affordable_units DESC, project_id) AS project_rank
    FROM project_summary
)
SELECT
    project_rank,
    project_id,
    project_name,
    deep_affordable_units,
    contribution_pct,
    cumulative_contribution_pct
FROM project_contribution
ORDER BY project_rank;

-- 8.3 Strategic project segmentation
-- Business Question: How can projects be grouped according to their affordable housing scale and deep-affordability focus?
WITH project_summary AS (
    SELECT
        project_id,
        SUM(all_counted_units) AS affordable_units,
        SUM(extremely_low_income_units + very_low_income_units) AS deep_affordable_units
    FROM housing_projects
    GROUP BY project_id
),
project_metrics AS (
    SELECT
        project_id,
        affordable_units,
        deep_affordable_units,
        ROUND(deep_affordable_units * 100.0 / NULLIF(affordable_units, 0), 2) AS deep_affordability_share_pct
    FROM project_summary
),
benchmarks AS (
    SELECT
        AVG(affordable_units) AS avg_affordable_units_per_project,
        AVG(deep_affordability_share_pct) AS avg_deep_affordability_share_pct
    FROM project_metrics
)
SELECT
    CASE
        WHEN affordable_units >= avg_affordable_units_per_project
             AND deep_affordability_share_pct >= avg_deep_affordability_share_pct
            THEN 'Large & Deeply Affordable'
        WHEN affordable_units >= avg_affordable_units_per_project
             AND deep_affordability_share_pct < avg_deep_affordability_share_pct
            THEN 'Large & Lower Deep Affordability'
        WHEN affordable_units < avg_affordable_units_per_project
             AND deep_affordability_share_pct >= avg_deep_affordability_share_pct
            THEN 'Small & Deeply Affordable'
        ELSE 'Small & Lower Deep Affordability'
    END AS strategic_segment,
    COUNT(*) AS projects,
    SUM(affordable_units) AS total_affordable_units,
    ROUND(AVG(affordable_units), 2) AS avg_affordable_units,
    ROUND(AVG(deep_affordability_share_pct), 2) AS avg_deep_affordability_share_pct
FROM project_metrics
	CROSS JOIN benchmarks
GROUP BY strategic_segment
ORDER BY total_affordable_units DESC;