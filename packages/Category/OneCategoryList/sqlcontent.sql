/*select c.categid, c.categname, s.subcategid, s.subcategname from category_v1 c
left join subcategory_v1 s on s.categid=c.categid
order by c.categname, s.subcategname*/
SELECT 
c.transid AS Nr
, c.transdate as Date
, case ifnull(c.categid, -1) when -1 then s.categid else c.categid end categ_id
,  (case ifnull(s.splittransid, -1) when -1 then c.transamount else s.splittransamount end)
    *(case c.transcode when 'Deposit' then 1 else -1 end) as Amount
,  (case ifnull(s.splittransid, -1) when -1 then c.transamount else s.splittransamount end)
    *(case c.transcode when 'Deposit' then 1 else -1 end) *CURR.baseconvrate as BaseAmount
, curr.PFX_SYMBOL, curr.SFX_SYMBOL
, ac.ACCOUNTNAME
, p.payeename
, c.notes as Notes
, i.infovalue AS COLOR
, (SELECT GROUP_CONCAT(t.FileName) AS TagList
    FROM Checkingaccount_v1 AS a
     LEFT JOIN Attachment_v1 AS at
       ON at.RefId = a.TransId
     LEFT JOIN Attachment_v1 AS t
       ON t.AttachmentId = at.AttachmentId
    where a.transid = c.transid
    GROUP BY a.transid) AS Files
FROM checkingaccount_v1 C
    LEFT JOIN payee_v1 p ON p.payeeid=c.payeeid 
    INNER JOIN accountlist_v1 AC ON C.accountid = AC.accountid
    INNER JOIN currencyformats_v1 CURR ON AC.currencyid = CURR.currencyid
    LEFT JOIN splittransactions_v1 s ON s.transid=c.transid
    LEFT JOIN infotable_v1 i ON i.INFONAME = 'USER_COLOR'||c.followupid
where categ_id=1 /*category ID*/

ORDER BY c.transdate desc
