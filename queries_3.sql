--שאלה 1) לכל כנסת החזר את מספר המפלגות השונות בהן כיהנו חברי כנסת באותה הכנסת.
-- יש להחזיר טבלה עם העמודות number,partyCount ממוינת לפי number
SELECT number, COUNT(DISTINCT party) AS partyCount
FROM memberinknesset
GROUP BY number
ORDER BY number;

--שאלה 2) לכל כנסת החזר את הגיל הממוצע של חברי הכנסת שכיהנו באותה הכנסת .
-- יש להחזיר טבלה עם העמודות number,avgAge ממוינת לפי number
SELECT number, AVG(k.startyear - m.birthyear) AS partyCount
FROM memberinknesset mik
         NATURAL JOIN knessets k
         NATURAL JOIN members m
GROUP BY number
ORDER BY number;


--שאלה 3)  (נאמר שחבר כנסת הוא מתמיד נאמן, אם כיהן לפחות בחמש כנסות שונות (לאו דווקא ברצף),
-- ובנוסף,כיהן עבור מפלגה אחת בלבד לאורך כל כהונותיו בכנסת.
-- החזר את שמות כל חברי הכנסה תמתמידים-נאמנים.
-- יש להחזיר טבלה עם העמודה name ממוינת לפי name

SELECT MAX(name) as name
FROM members
NATURAL JOIN memberInKnesset
GROUP BY uid
HAVING COUNT(DISTINCT party) = 1 AND COUNT(number) >= 5
ORDER BY MAX(name);


--שאלה 4) לכל כנסת, החזר את המפלגה הכי גדולה(כלומר שכיהנו מטעמה בכנסת זו הכי הרבה חברי כנסת)
--ואת מספר חברי הכנסת מאותה מפלגה באותה הכנסת. יש להחזיר טבלה עם העמודות number,party,memberCount
-- ממויינת לפי number ומיון שניוני לפי party.
-- אם יש כמה מפלגות גדולות ביותר באותה כנסת, יש להחזיר את כולם, כל אחת בשורה נפרדת.
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




--שאלה 5) נאמר שמפלגה היא מקדמת נשים אם יש כנסת בה לפחות %30 מחברי הכנסת באותה מפלגה היו נשים.
--מצאו את כל המפלגות שהיו מקדמות נשים בלפחות כנסת אחת.
--  יש להחזיר את כל הכנסות בהם המפלגה קידמה נשים
--יש להחזיר טבלה עם העמודות party,number,femalePercent ממויין לפי party ואז לפי number.

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


--  6) נאמר שהמרחק בין שני חברי כנסת m1 ו- m2 הוא 1 אם שניהם כיהנו באותה הכנסת עבור אותה המפלגה.
-- בהמשך לכך, אם חבר כנסת m3 כיהן באותה הכנסת עבור אותה המפלגה כמו m2 (אך לא עם m1) נגיד שm1 וm3 הם במרחק 2.
--
-- למשל, גאולה כהן כיהנה בכנסת ה-8 יחד עם מנחם בגין במפלגת הליכוד, ולכן היא במרחק 1 ממנו.
-- חנן פורת לא כיהן בכנסת ה-8 ,אבל כן כיהן יחד גם גאולה כהן בכנסת ה-10 במפלגת תחיה לכן הוא במרחק 2 ממנחם בגין.
--כתבו שאילתה רקורסיבית אשר מחזירה את כל חברי הכנסת שהמרחק שלהם ממנחם בגין (Menachem Begin) גדול מ3.
--יש להחזיר טבלה עם עמודה אחת ממוינת בשם name ובה שמות חברי הכנסת.
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
