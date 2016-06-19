#!python_local/bin/python

import os,sys
import cgi,cgitb

cgitb.enable()

# using username and image folder, return a list of jpegs from that folder

rosterFolder = 'rosters/'
etcFolder = 'etc/'
pwfile = etcFolder+'pw'
sentinel = '_S__S_'

def space_escape(s):
        return s.replace(' ','%20')

def space_unescape(s):
        return s.replace('%20',' ')

form = cgi.FieldStorage()
name = space_escape(form['name'].value)
imgFolder = space_escape(form['imgFolder'].value)

print("Content-Type:text/html\n")

# get a list of jpegs in the users directory
fullImageFolder = rosterFolder+name+'/'+imgFolder
rosters = os.listdir(fullImageFolder)

# filter for only .jpg images 
rosters = [x for x in rosters if x.endswith('.jpg')]

# sort the list
rosters.sort()

for f in rosters:
        print f
