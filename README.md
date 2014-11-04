general-reports
===============

General reports for [Money Manager Ex](https://sourceforge.net/projects/moneymanagerex/) which can be [downloaded](https://github.com/moneymanagerex/general-reports/releases/latest) and imported easily.
Reports can be created using Money Manager Ex as well.
![compose general report](https://raw.githubusercontent.com/moneymanagerex/moneymanagerex/master/doc/help/GRM.gif)


[![Build Status](https://secure.travis-ci.org/moneymanagerex/general-reports.png)](http://travis-ci.org/moneymanagerex/general-reports)

Typically, one general report contains:
------------
1. sqlcontent.sql (MMEX will execute this sql first to return one result set)
  * sql
  ~~~sql
  select * from assets_v1;
  ~~~
2. luacontent.lua (There are two APIs here)
  * handle_record
  ~~~lua
  function handle_record(record)
      // Your logic to modify a record and apply this function against every record from SQL.
     record:set("extra_value", record::get("VALUE") * 2);
  end
  ~~~
  * complete
  ~~~lua
  function complete(result)
     // Put some accumulated value and apply this function after SQL completes.
     result:set("TOTAL", 1000);
  end
  ~~~
3. template.htt (a plain text template file powered by [html template](https://github.com/moneymanagerex/html-template))

## Contributing
1. Fork the [repository] (http://github.com/moneymanagerex/general-reports)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## Donations
1. Star it
2. Donate to my Ripple address: `rUY7DvWqNnSYCYiVr986W71tuaKtDCMNz3` 
3. [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=moneymanagerex%40gmail%2ecom&lc=US&item_name=MoneyManagerEx&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest)
