SELECT 
    account.ACCOUNTNAME, 
    account.INITIALBAL, 
    txn.*
FROM CHECKINGACCOUNT_V1 AS txn
JOIN ACCOUNTLIST_V1 AS account 
    ON txn.ACCOUNTID = account.ACCOUNTID 
    OR txn.TOACCOUNTID = account.ACCOUNTID
WHERE 
    account.ACCOUNTTYPE = 'Investment' 
    AND account.STATUS = 'Open';
