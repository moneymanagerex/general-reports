One Category List
===============

This report shows transactions for the specified category.

Edit line 31 of SQL script to get proper data.

Get category ID using this SQL script:

~~~sql
WITH RECURSIVE categories(categid, categname, parentid) AS 
(SELECT a.categid, a.categname, a.parentid FROM category_v1 a WHERE parentid = '-1' 
UNION ALL 
SELECT c.categid, r.categname || ':' || c.categname, c.parentid 
FROM categories r, category_v1 c 
WHERE r.categid = c.parentid) 
 SELECT categid, categname FROM categories ORDER by categname;
~~~
![how to get categories IDs](https://raw.githubusercontent.com/moneymanagerex/general-reports/master/packages/Category/OneCategoryList/get_categs_sample.png "how to get categories IDs")

