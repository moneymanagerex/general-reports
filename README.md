general-reports
===============

Bunch of general reports for [Money Manager Ex](https://sourceforge.net/projects/moneymanagerex/).

[![Build Status](https://secure.travis-ci.org/moneymanagerex/general-reports.png)](http://travis-ci.org/moneymanagerex/general-reports)

Typically, one general report contains the following files
------------
1. sqlcontent.sql (MMEX will execute this sql firstly to return one result set)
  * for instance
  ~~~sql
  select * from assets_v1;
  ~~~
2. luacontent.lua (There are two APIs here)
  * handle_record
  ~~~lua
  function handle_record(record)
      // put your logic to modify record and apply this function against every record from SQL
     record:set("extra_value", record::get("VALUE") * 2);
  end
  ~~~
  * complete
  ~~~lua
  function complete(result)
     // put some accumulated value and apply this funciton after SQL complete
     result:set("TOTAL", 1000);
  end
  ~~~
3. template.htt (plain text template file powered by [html template](https://github.com/moneymanagerex/html-template))

## Contributing
1. Fork [it] (http://github.com/moneymanagerex/general-reports)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Donations
1. Do a donate at my Ripple address: `rUY7DvWqNnSYCYiVr986W71tuaKtDCMNz3` 
2. [PayPal](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=moneymanagerex%40gmail%2ecom&lc=US&item_name=MoneyManagerEx&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHostedGuest)
