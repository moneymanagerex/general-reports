#!/usr/bin/env python
# vi:tabstop=4:expandtab:shiftwidth=4:softtabstop=4:autoindent:smarttab

import os
import sqlite3

def check(curs, report):
    print 'checking %s' % report
    sql = ''
    for line in open(os.path.join(report, 'sqlcontent.sql'), 'rb'):
        sql = sql + line
    curs.execute(sql)
    print 'done %s' % report

if __name__ == '__main__':
    conn = sqlite3.connect(':memory:')
    conn.row_factory = sqlite3.Row 
    curs = conn.cursor()
    sql = ''
    for line in open('./database/tables.sql', 'rb'):
        sql = sql + line
    curs.executescript(sql)
    for report in os.listdir('.'):
        if not report.startswith('.') and os.path.isdir(report):
            try:
                check(curs, report)
            except Exception as e:
                exit(1)
    conn.close()
    exit(0)
    
