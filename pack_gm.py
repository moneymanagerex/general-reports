#!/usr/bin/env python
# vi:tabstop=4:expandtab:shiftwidth=4:softtabstop=4:autoindent:smarttab

import os
import zipfile

def pack_report(subdir, package):
    root_path = os.path.dirname(os.path.realpath(__file__))
    print ('~~|zip|~~ ', subdir.ljust(65),  package + '.zip')
    valid_names = ['description.txt', 'luacontent.lua', 'sqlcontent.sql', 'template.htt']
    f = zipfile.ZipFile(package + '.zip', 'w')
    os.chdir(subdir)
    for item in valid_names:
        f.write(item)
    f.close()
    os.chdir(root_path)

if __name__ == '__main__':
    path = 'packages'
    
    for subdir, dirs, files in os.walk(path):
        file_count = len(files)    
        if file_count < 4: continue
        path, subfolder = os.path.split(subdir)
        try:
            pack_report(subdir, subfolder)
        except:
            print ('[X] Exception')
            exit(1)
    print ('[V] OK')
    exit(0)
