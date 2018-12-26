#!/usr/bin/env python
# vi:tabstop=4:expandtab:shiftwidth=4:softtabstop=4:autoindent:smarttab

import os
import zipfile

def pack_report(report):
    print ('packing', report)
    f = zipfile.ZipFile(report + '.zip', 'w')
    for item in os.listdir(report):
        f.write(os.path.join(report, item))
    f.close()

if __name__ == '__main__':
    for report in os.listdir('.'):
        if not report.startswith('.') and os.path.isdir(report):
            try:
                pack_report(report)
            except:
                exit(1)
    exit(0)
    
