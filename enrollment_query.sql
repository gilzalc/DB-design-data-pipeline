SELECT 
  YearData.year AS year, 
  Country.countryname AS country_name, 
  AVG(YearData.students5_estimated) AS avg_students 
FROM 
  YearData 
  JOIN University ON YearData.iau_id1 = University.iau_id1 
  JOIN Country ON University.countrycode = Country.countrycode 
GROUP BY 
  YearData.year, 
  Country.countryname 
HAVING 
  COUNT(DISTINCT University.uniname) >= 5 
ORDER BY 
  year ASC, 
  avg_students DESC;
