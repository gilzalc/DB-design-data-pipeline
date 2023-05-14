--שאלה 1) החזר את שמות חברי הכנסת שלמדו באוניברסיטה העברית ונולדו אחרי 1970.
--יש להחזיר טבלה עם העמודה name ממויינת לפי name
SELECT name
FROM members
WHERE birthyear > 1970
  AND educatedat = 'Hebrew University of Jerusalem'
ORDER BY name;
--שאלה 2) החזר את שמות חברי הכנסת שכיהנו בכנסת הראשונה, ואת שם המפלגה אותה הם ייצגו:
--יש להחזיר טבלה עם העמודות, name,party ממויין מיון ראשוני לפי name ומיון שניוני לפי party.

SELECT name, party
FROM members
         NATURAL JOIN memberinknesset
WHERE number = 1
ORDER BY name, party;
--  שאלה 3) מצא את חברי הכנסת ממפלגות ליכוד )Likud )או מרץ )Meretz )שהתחילו כהונה בכנסת כלשהי כשהיו מעל גיל 70 .
-- החזירו את שם חבר הכנסת והכנסת בה הוא כיהן. יש להחזיר טבלה עם העמודות number, name
-- ממויין מיון ראשוני לפי name ומיון שניוני לפי number.
SELECT DISTINCT name, k.number
FROM members
         NATURAL JOIN memberinknesset m
         NATURAL JOIN knessets k
WHERE m.party IN ('Likud', 'Meretz')
  AND (k.startyear - members.birthyear)
    > 70
ORDER BY members.name, k.number;

-- מצא את חברות הכנסת שהמקצוע שלהן הוא לא פוליטיקאי )politician ,)והן כיהנו גם בכנסת ה-23 וגם בכנסת ה-24.
--  .החזר את השם של כל חברת כנסת. יש להחזיר טבלה עם העמודה name ממויינת לפי name

WITH B(name, number) AS (SELECT name, number
                         FROM members
                                  NATURAL JOIN memberinknesset
                                  NATURAL JOIN knessets k
                         WHERE occupation != 'politician'
                           AND gender = 'female')
SELECT name
FROM B
WHERE number = 23
INTERSECT
SELECT name
FROM B
WHERE number = 24
ORDER BY name;

-- )החזר את את שמות חברי הכנסת שנולדו בירושלים וכיהנו בכנסת אחת בדיוק. יש להחזיר טבלה עם
-- העמודה name ,ממויין לפי name

SELECT name
FROM members m
         NATURAL JOIN (SELECT uid
                       FROM memberinknesset
                       GROUP BY uid
                       HAVING COUNT(*) = 1) AS single
WHERE m.birthplace = 'Jerusalem'
ORDER BY name;

-- Other solution
SELECT m.name
FROM members m
         NATURAL JOIN(SELECT *
                      FROM memberinknesset mi1
                      WHERE NOT EXISTS (SELECT *
                                        FROM memberinknesset mi2
                                        WHERE mi1.uid = mi2.uid
                                          AND mi1.number <> mi2.number)) AS e
WHERE m.birthplace = 'Jerusalem'
ORDER BY name;


-- שאלה 6) החזר את את שמות חברי הכנסת שכיהנו כחברי מפלגת מפא"י )Mapai )בכל הכנסות שבהם כיהן גם דוד
-- בן גוריון כחבר מפלגת מפא"י. יש להחזיר טבלה עם העמודה name ,ממויין לפי name
-- לתקן- כל הכנסות

WITH A(name, num, uid) AS (SELECT name, number, uid
                           FROM (memberinknesset mi
                               NATURAL JOIN members m) AS m3
                           WHERE m3.party = 'Mapai'
                             AND m3.number IN (SELECT number
                                               FROM memberinknesset mi2
                                                        NATURAL JOIN members m2
                                               WHERE mi2.party = 'Mapai'
                                                 AND name = 'David Ben-Gurion'))
SELECT DISTINCT name
FROM A
WHERE NOT EXISTS (SELECT DISTINCT num
                  FROM A
                  EXCEPT
                  SELECT num
                  FROM A a2
                  WHERE A.uid = a2.uid)
ORDER BY name;


-- //*********************
WITH X(number) AS (SELECT DISTINCT number
                   FROM memberinknesset mi2
                            INNER JOIN members m2 ON m2.uid = mi2.uid
                   WHERE mi2.party = 'Mapai')
SELECT name
FROM members m

         INNER JOIN memberinknesset mi ON m.uid = mi.uid
WHERE mi.party = 'Mapai'
  AND mi.number IN (SELECT * FROM X)
GROUP BY name
HAVING COUNT(mi.number) =
       (SELECT COUNT(*)
        FROM X)
ORDER BY name;



-- SELECT name
-- FROM members m
--          INNER JOIN memberinknesset mi ON m.uid = mi.uid
-- WHERE mi.party = 'Mapai'
--   AND mi.number IN
--       (SELECT number
--        FROM memberinknesset mi2
--                 INNER JOIN members m2 ON m2.uid = mi2.uid
--        WHERE m2.name = 'David Ben-Gurion'
--          AND mi2.party = 'Mapai')
-- GROUP BY name
-- HAVING COUNT(DISTINCT mi.number) =
--        (SELECT COUNT(DISTINCT number)
--         FROM memberinknesset mi3
--                  INNER JOIN members m3 ON m3.uid = mi3.uid
--         WHERE m3.name = 'David Ben-Gurion'
--           AND mi3.party = 'Mapai')
-- ORDER BY name;


-- שאלה 7:
--נאמר שחבר כנסת הוא "המבוגר האחראי" של הכנסת אם הוא חבר הכנסת המבוגר ביותר המכהן באותה הכנסת.
--  שימו לב שיכולים להיות כמה "מבוגרים אחראים" באותה כנסת.
-- עבור כל כנסת, החזירו שורה, או שורות במקרה של מספר "מבוגרים אחראים", מהצורה (k,n) כאשר k הוא מספר הכנסת, ו n הוא שם המבוגר האחראי באותה הכנסת.
-- יש להחזיר טבלה עם העמודות name,number ממיונן במיון ראשוני לפי number ומיון שניוני לפי name.


WITH MnI(number, name, uid, birthYear) AS (SELECT number, name, m.uid, birthYear
                                           FROM members M
                                                    NATURAL JOIN memberinknesset)
SELECT number, name
FROM MnI
EXCEPT

SELECT m1.number, m1.name
FROM MnI m1
         INNER JOIN MnI AS m2 ON m1.number = m2.number
WHERE m1.birthYear > m2.birthYear
ORDER BY number, name;
