One Category List
===============

This report shows transactions for the specified category.

Edit line 32 of SQL script to get proper data.

Get category ID and subcategory ID using this SQL script:

~~~sql
select c.categid, c.categname, s.subcategid, s.subcategname from category_v1 c<br>
left join subcategory_v1 s on s.categid=c.categid
order by c.categname, s.subcategname
~~~
![how to get categories IDs](https://raw.githubusercontent.com/moneymanagerex/general-reports/master/packages/Category/OneCategoryList/get_categs_sample.png "how to get categories IDs")

