
SELECT number, COUNT(DISTINCT party) AS partyCount
FROM memberinknesset
GROUP BY number
ORDER BY number;


SELECT number, AVG(k.startyear - m.birthyear) AS partyCount
FROM memberinknesset mik
         NATURAL JOIN knessets k
         NATURAL JOIN members m
GROUP BY number
ORDER BY number;




SELECT MAX(name) as name
FROM members
NATURAL JOIN memberInKnesset
GROUP BY uid
HAVING COUNT(DISTINCT party) = 1 AND COUNT(number) >= 5
ORDER BY MAX(name);



SELECT k.number, mik.party, COUNT(*) AS memberCount
FROM knessets k
         NATURAL JOIN memberinknesset mik
GROUP BY party, k.number
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM knessets k1
                                 NATURAL JOIN memberinknesset mik1
                        WHERE number = k.number
                        GROUP BY mik1.party)
ORDER BY number, party;


 WITH B(number, party, Cnt) AS (SELECT m.number, m.party, count(DISTINCT m.uid)
 FROM memberinknesset m
 Group by m.number, m.party)
 SELECT b1.number, b1.party, b1.Cnt as memberCount FROM B b1
 WHERE NOT EXISTS(Select * from B b2
 where b1.number = b2.number and b1.Cnt < b2.Cnt)
 ORDER BY number, party;




WITH T1(party, number, gender) AS (SELECT party,
                                          number,
                                          ((CASE
                                                WHEN gender = 'female'
                                                    THEN 1
                                                ELSE 0
                                              END
                                              )::decimal)
                                   FROM members
                                            NATURAL JOIN memberinknesset)


SELECT party, number, ROUND(SUM(gender) / COUNT(*) * 100) AS femalePercent
FROM T1
GROUP BY party, number
HAVING 0.3 <= (SUM(gender)) / (COUNT(*))
ORDER BY party, number;



WITH RECURSIVE T1(uid, party, number, dist) AS
                   (SELECT M.uid, MIK.party, MIK.number, 0 AS dist
                    FROM members M
                             NATURAL JOIN memberInKnesset MIK
                    WHERE M.uid = 130873 --Begin's uid

                    UNION

                    SELECT DISTINCT MIK2.uid, T1.party, T1.number, T1.dist + 1
                    FROM T1
                             JOIN memberInKnesset MIK1 ON T1.uid = MIK1.uid
                             JOIN memberInKnesset MIK2
                                  ON MIK1.party = MIK2.party AND MIK1.number = MIK2.number
                    WHERE T1.dist < 3)
SELECT DISTINCT name
FROM members
WHERE NOT EXISTS (SELECT * FROM T1 WHERE T1.uid = members.uid)
ORDER BY name;
