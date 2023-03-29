--1. ¿Cómo se ha comparto el tráfico en las distintas ciudades del mundo debido a las distintas olas de casos de pandemia?
-- Atlanta (y otras ciudades de USA, solo se cambia la linea 11 con el nombre de la ciudad)
SELECT congestion, daily_confirmed_cases, date, date_c FROM (SELECT *
FROM (
    SELECT date(year, month , day) as date_c, congestion
    FROM (
        SELECT EXTRACT(DAY FROM date_time) as day, EXTRACT(MONTH FROM date_time) as month, EXTRACT(YEAR FROM date_time) as year, AVG(percent_congestion) as congestion
        FROM (
            SELECT * 
            FROM`bigquery-public-data.covid19_geotab_mobility_impact.city_congestion` 
            WHERE city_name = 'Atlanta'
            )
        GROUP BY day, month, year
    )
) A
LEFT JOIN (
    SELECT date, daily_confirmed_cases/1000 as  daily_confirmed_cases
    FROM`bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
    WHERE country_territory_code = 'USA'
) B ON A.date_c = B.date);
-- Ciudad de Mexico
SELECT congestion, daily_confirmed_cases, date, date_c FROM (SELECT *
FROM (
    SELECT date(year, month , day) as date_c, congestion
    FROM (
        SELECT EXTRACT(DAY FROM date_time) as day, EXTRACT(MONTH FROM date_time) as month, EXTRACT(YEAR FROM date_time) as year, AVG(percent_congestion) as congestion
        FROM (
            SELECT * 
            FROM`bigquery-public-data.covid19_geotab_mobility_impact.city_congestion` 
            WHERE city_name = 'Ciudad de México'
            )
        GROUP BY day, month, year
    )
) A
LEFT JOIN (
    SELECT date, daily_confirmed_cases/500 as  daily_confirmed_cases
    FROM`bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
    WHERE country_territory_code = 'MEX'
) B ON A.date_c = B.date);

--2. ¿Cuáles países en el mundo han tenido la mayor tasa de crecimiento de casos activos durante la pandemia?
SELECT countries_and_territories, AVG(daily_confirmed_cases) average_daily_cases
FROM `bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
GROUP BY countries_and_territories
ORDER BY average_daily_cases DESC;

--3. ¿Cómo ha variado la tasa de recuperación de Covid19 en los distintos países del mundo?
SELECT country_name, date, SUM(new_recovered) recuperados_diarios
FROM `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE new_recovered IS NOT NULL
GROUP BY country_name, date;

-- 4.1. ¿Cuál es el top 10 países en razón muertes/casos en el mundo?
SELECT countries_and_territories, (deaths/ confirmed_cases) razon_muertes_casos
FROM `bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
WHERE date = '2020-12-14'
ORDER BY razon_muertes_casos DESC;

--5.1. ¿Existió un cambio en este tipo de búsquedas entre la era pre-covid y post-covid?
SELECT EXTRACT(YEAR FROM date) as year, AVG(symptom_Acute_bronchitis) bronquitis, AVG(symptom_Allergy) alergia, 
    AVG(symptom_Conjunctivitis) conjuntivitis, AVG(symptom_Cough) tos, AVG(symptom_Diarrhea) diarrea, 
    AVG(symptom_Fatigue) fatiga, AVG(symptom_Fever) fiebre, AVG(symptom_Headache) dolor_cabeza,
    AVG(symptom_Nasal_congestion) congestion_nasal,AVG(symptom_Nausea) nausea, AVG(symptom_Pain) dolor,
    AVG(symptom_Sinusitis) sinusitis,AVG(symptom_Sore_throat) dolor_garganta, AVG(symptom_Vomiting) vomito
FROM `bigquery-public-data.covid19_symptom_search.symptom_search_country_daily`
GROUP BY year
ORDER BY year;

--5.2. ¿Qué país tuvo el mayor cambio en dicho impacto?
SELECT A.country_region, ((alergia2 -alergia) + (conjuntivitis2 - conjuntivitis) + 
    (tos2 -tos) + (diarrea2 - diarrea) + (fatiga2 - fatiga) + (fiebre2 - fiebre) +
    (dolor_cabeza2 - dolor_cabeza) + (congestion_nasal2 - congestion_nasal) +
    (nausea2 - nausea) + (sinusitis2 - sinusitis) + (dolor_garganta2 - dolor_garganta) +
    (vomito2 - vomito)) diferencia_total
 FROM (   
    SELECT country_region, AVG(symptom_Allergy) alergia, AVG(symptom_Conjunctivitis) conjuntivitis,
        AVG(symptom_Cough) tos, AVG(symptom_Diarrhea) diarrea, AVG(symptom_Fatigue) fatiga,
        AVG(symptom_Fever) fiebre, AVG(symptom_Headache) dolor_cabeza,
        AVG(symptom_Nasal_congestion) congestion_nasal,AVG(symptom_Nausea) nausea,
        AVG(symptom_Sinusitis) sinusitis,AVG(symptom_Sore_throat) dolor_garganta, AVG(symptom_Vomiting) vomito
    FROM (
        SELECT * 
        FROM `bigquery-public-data.covid19_symptom_search.symptom_search_country_daily`
        WHERE EXTRACT(YEAR FROM date) < 2019
    )
    GROUP BY country_region
 ) A
JOIN (
    SELECT country_region, AVG(symptom_Allergy) alergia2, AVG(symptom_Conjunctivitis) conjuntivitis2,
        AVG(symptom_Cough) tos2, AVG(symptom_Diarrhea) diarrea2, AVG(symptom_Fatigue) fatiga2,
        AVG(symptom_Fever) fiebre2, AVG(symptom_Headache) dolor_cabeza2,
        AVG(symptom_Nasal_congestion) congestion_nasal2, AVG(symptom_Nausea) nausea2,
        AVG(symptom_Sinusitis) sinusitis2, AVG(symptom_Sore_throat) dolor_garganta2, AVG(symptom_Vomiting) vomito2
    FROM (
        SELECT * 
        FROM `bigquery-public-data.covid19_symptom_search.symptom_search_country_daily`
        WHERE EXTRACT(YEAR FROM date) > 2019
    )
    GROUP BY country_region
) B ON B.country_region = A.country_region
ORDER BY diferencia_total DESC;

--6. En el año 2021. ¿Cuáles síntomas de enfermedades respiratorias, siguen prevaleciendo como búsqueda en la población?
SELECT *
FROM (
    SELECT '2017-2018' year, AVG(symptom_Acute_bronchitis) bronchitis_aguda, 
        AVG(symptom_Asphyxia) asfixia, AVG(symptom_Asthma) asma, AVG(symptom_Anosmia) anosmia,
        AVG(symptom_Bronchitis) bronquitis, AVG(symptom_Croup) croup, AVG(symptom_Pneumonia) neumonia,
        AVG(symptom_Esophagitis) esofagitis, AVG(symptom_Pulmonary_edema) edema_pulmonar,
        AVG(symptom_Pulmonary_hypertension) hipertension_pulmonar, AVG(symptom_Tonsillitis) amigdalitis,
        AVG(symptom_Sinusitis) sinusitis, AVG(symptom_Rhinitis) rinitis
    FROM (
        SELECT *
        FROM `bigquery-public-data.covid19_symptom_search.symptom_search_country_daily`
        WHERE EXTRACT(YEAR FROM date) < 2019
    )
) A
UNION ALL (
   SELECT '2021' year, AVG(symptom_Acute_bronchitis) bronchitis_aguda, 
        AVG(symptom_Asphyxia) asfixia, AVG(symptom_Asthma) asma, AVG(symptom_Anosmia) anosmia,
        AVG(symptom_Bronchitis) bronquitis, AVG(symptom_Croup) croup, AVG(symptom_Pneumonia) neumonia,
        AVG(symptom_Esophagitis) esofagitis, AVG(symptom_Pulmonary_edema) edema_pulmonar,
        AVG(symptom_Pulmonary_hypertension) hipertension_pulmonar, AVG(symptom_Tonsillitis) amigdalitis,
        AVG(symptom_Sinusitis) sinusitis, AVG(symptom_Rhinitis) rinitis
    FROM (
        SELECT *
        FROM `bigquery-public-data.covid19_symptom_search.symptom_search_country_daily`
        WHERE EXTRACT(YEAR FROM date) = 2021
    )
);

--7. ¿Cuál tipo de movilidad fue la mas afectada? ¿comercial, recreacional, laboral, residencial?
-- Promedio
SELECT 'recreacional' tipo, AVG(retail_and_recreation_percent_change_from_baseline) promedio_porcentaje_cambio, 
FROM `bigquery-public-data.covid19_google_mobility.mobility_report`
UNION ALL 
SELECT 'comercial' tipo, AVG(grocery_and_pharmacy_percent_change_from_baseline) promedio_porcentaje_cambio, 
FROM `bigquery-public-data.covid19_google_mobility.mobility_report`  
UNION ALL
SELECT 'laboral' tipo, AVG(workplaces_percent_change_from_baseline) promedio_porcentaje_cambio, 
FROM `bigquery-public-data.covid19_google_mobility.mobility_report`  
UNION ALL
SELECT 'residencial' tipo, AVG(residential_percent_change_from_baseline) promedio_porcentaje_cambio, 
FROM `bigquery-public-data.covid19_google_mobility.mobility_report`;
-- Cambio en el tiempo
SELECT date fecha, AVG(retail_and_recreation_percent_change_from_baseline) recreacional, 
    AVG(grocery_and_pharmacy_percent_change_from_baseline) comercial, 
    AVG(workplaces_percent_change_from_baseline) laboral, 
    AVG(residential_percent_change_from_baseline) residencial
FROM `bigquery-public-data.covid19_google_mobility.mobility_report`
GROUP BY date
ORDER BY date DESC;

--8. ¿Podríamos inferir alguna relación entre el clima de las distintas áreas de USA con el comportamiento de los casos activos de Covid19?
SELECT A.date, AVG(avg_temperature_air_2m_f) temperatura_promedio, AVG(avg_humidity_relative_2m_pct) humedad_promedio, AVG(B.daily_confirmed_cases) casos_diarios
FROM `bigquery-public-data.covid19_weathersource_com.county_day_history` A
LEFT JOIN (
    SELECT date, daily_confirmed_cases/1000 as daily_confirmed_cases
    FROM`bigquery-public-data.covid19_ecdc.covid_19_geographic_distribution_worldwide`
    WHERE country_territory_code = 'USA'
) B ON A.date = B.date
GROUP BY date
ORDER BY date;

--9. ¿Cuáles regiones de USA tienen poco interés en vacunarse contra Covid19?
-- Por estado
SELECT sub_region_1, AVG(sni_covid19_vaccination) sni_covid19_vaccination
FROM `bigquery-public-data.covid19_vaccination_search_insights.covid19_vaccination_search_insights`
WHERE sni_covid19_vaccination IS NOT NULL
GROUP BY sub_region_1
ORDER BY sni_covid19_vaccination;
-- Por condado
SELECT sub_region_2, AVG(sni_covid19_vaccination) sni_covid19_vaccination
FROM `bigquery-public-data.covid19_vaccination_search_insights.covid19_vaccination_search_insights`
WHERE sni_covid19_vaccination IS NOT NULL
GROUP BY sub_region_2
ORDER BY sni_covid19_vaccination;