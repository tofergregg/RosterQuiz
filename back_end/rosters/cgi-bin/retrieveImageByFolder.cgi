#!python_local/bin/python

import os,sys
import cgi,cgitb

cgitb.enable()

# using username, pw, and .jpg name, send the image 

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
folder = space_escape(form['imgFolder'].value) 
imgName = form['imgName'].value

# get a list of jpegs in the users directory
imageFolder = rosterFolder+name+'/'+folder+'/'
fullImageName = imageFolder+imgName

print("Content-Type:image/jpeg\n")

with open(fullImageName,"rb") as f:
        sys.stdout.write(f.read())
