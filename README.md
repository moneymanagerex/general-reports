general-reports
===============

Bunch of general reports for Money Manager Ex.

Typically, one general report contain the following files
------------
1. sqlcontent.sql (MMEX will execute this sql firstly to return one result set)
  * for instance
  ~~~
  select * from assets_v1;
  ~~~
2. luacontent.lua (There are two APIs here)
  * handle_record
  ~~~
  function handle_record(record)
      // put your logic to modify record
  end
  ~~~
  * complete
  ~~~
  function complete(result)
    // xxx
  end
  ~~~
3. template.htt (purl plain text template file powere by [html template](https://github.com/moneymanagerex/html-template))

Contributing
------------

1. Fork [it] (http://github.com/moneymanagerex/general-reports)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
