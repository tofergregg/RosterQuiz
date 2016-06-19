#!python_local/bin/python

import bcrypt
import os,sys
import cgi,cgitb

cgitb.enable()

# using username, pw, and .jpg name, send the image 

imageFolderExt = '_images/'
etcFolder = 'etc/'
pwfile = etcFolder+'pw'
sentinel = '_S__S_'

def space_escape(s):
        return s.replace(' ','%20')

def space_unescape(s):
        return s.replace('%20',' ')

def get_hashed_password(plain_text_password):
    # Hash a password for the first time
    #   (Using bcrypt, the salt is saved into the hash itself)
    return bcrypt.hashpw(plain_text_password, bcrypt.gensalt())

def check_password(plain_text_password, hashed_password):
    # Check hased password. Useing bcrypt, the salt is saved into the hash
    return bcrypt.checkpw(plain_text_password, hashed_password)

def user_ok(name,pw):
        with open (pwfile,"r") as f:
                for line in f:
                        line = line[:-1] # remove newline
                        if line.startswith(name):
                                oldName,pwHash=line.split(',')

                                if oldName == name:
                                        # salted password
                                        return check_password(name+pw,pwHash)
                # got to end of file with no name found...
                return False

form = cgi.FieldStorage()
name = space_escape(form['name'].value)
pw = form['pw'].value 
imgName = form['imgName'].value

# check pw
if not user_ok(name,pw):
        print("Content-Type:text/html\n")
        print("User name and password do not match!")
        quit()

# user is okay, so we can continue

# get a list of jpegs in the users directory
imageFolder = name+imageFolderExt
imageName = imageFolder+imgName

print("Content-Type:image/jpeg\n")

with open(imageName,"rb") as f:
        sys.stdout.write(f.read())
