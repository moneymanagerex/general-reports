#!/usr/bin/env python3
# vi:tabstop=4:expandtab:shiftwidth=4:softtabstop=4:autoindent:smarttab

import os, sys
import sqlite3
import urllib.request

err = False
for version in range (7, 14):
    fname = 'tables_v1.sql' if version < 12 else 'tables.sql'
    url = 'https://cdn.jsdelivr.net/gh/moneymanagerex/database@v%i/%s' % (version, fname)
    schema = urllib.request.urlopen(url).read().decode('utf-8')
    db = sqlite3.connect(':memory:')
    db.executescript(schema)
    print('\nTesting reports with MMEX db schema v%i:' % version)
    print('-' * 40)
    for root, dirs, files in os.walk('.'):
        for sql in files:
            if sql=='sqlcontent.sql':
                try: db.executescript(open(os.path.join(root, sql)).read())
                except sqlite3.Error as e:
                    print('ERR', os.path.basename(root).ljust(40), e.args[0])
                    err = True
                else:
                    print('OK ', os.path.basename(root))
                db.rollback()
    db.close()
if err: sys.exit(1)
