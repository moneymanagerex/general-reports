#!/usr/bin/env python
# vi:tabstop=4:expandtab:shiftwidth=4:softtabstop=4:autoindent:smarttab

import os
import sqlite3

def check(curs, report):
    print 'checking %s' % report
    sql = ''
    for line in open(os.path.join(report, 'sqlcontent.sql'), 'r'):
        sql = sql + line
    curs.execute(sql)
    print 'done %s' % report

if __name__ == '__main__':
    conn = sqlite3.connect(':memory:')
    conn.row_factory = sqlite3.Row 
    curs = conn.cursor()
	print 'database created, loading schema...'
    sql = ''
    for line in open('tables_v1.sql', 'r'):
        sql = sql + line
		if line[len(line)] = ';':
			curs.executescript(sql)
			sql = ''
    
    anyNotPassed = False
    
    for report in os.listdir('.'):
        if not report.startswith('.') and os.path.isdir(report):
            try:
                check(curs, report)
            except:
                print 'ERR: %s' % report
    conn.close()
    
    if anyNotPassed:
        exit(1)
    
    exit(0)
    
