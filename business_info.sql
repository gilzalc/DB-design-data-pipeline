SELECT t_b.business_id1 AS business_id
     , business_lat
     , business_long
     , business_park
     , business_price
     , business_open
     , business_cat
     , n_photo
FROM (
-- table1: for business
         SELECT business_id                                      AS business_id1
              , latitude                                         AS business_lat
              , longitude                                        AS business_long
              , (
             CASE
                 WHEN attributes ->> 'BusinessParking' LIKE '%True%'
                 THEN 'true'
                 ELSE 'false'
                 END
             )                                                   AS business_park
              , attributes ->> 'RestaurantsPriceRange2'::integer AS business_price
              , is_open                                          AS business_open
              , categories                                       AS business_cat
         FROM public3.businesstable
         WHERE STRPOS(categories, 'Restaurants') <> 0
           AND city = 'Akron') AS t_b
         LEFT JOIN (
-- table2: for photos
    SELECT business_id AS business_id2
         , COUNT(*)    AS n_photo
    FROM public3.phototable
    GROUP BY business_id) AS t_p ON t_b.business_id1 = t_p.business_id2;
