#!python_local/bin/python

import os,sys
import cgitb,cgi
import bcrypt
import subprocess
from subprocess import Popen, PIPE

cgitb.enable()

rosterFolder = 'rosters/'
etcFolder = 'etc/'
pwfile = etcFolder+'pw'
sentinel = '_S__S_' # made this up out of nowhere...

def space_escape(s):
        return s.replace(' ','%20')

def space_unescape(s):
        return s.replace('%20',' ')

form = cgi.FieldStorage()
name = space_escape(form['name'].value)
rosterName = space_escape(form['rosterName'].value)
pw = form['pw'].value


def get_hashed_password(plain_text_password):
    # Hash a password for the first time
    #   (Using bcrypt, the salt is saved into the hash itself)
    return bcrypt.hashpw(plain_text_password, bcrypt.gensalt())

def check_password(plain_text_password, hashed_password):
    # Check hased password. Useing bcrypt, the salt is saved into the hash itself
    return bcrypt.checkpw(plain_text_password, hashed_password)

print("Content-Type:text/html\n")

# read in password file and look for user
known_user = False
with open (pwfile,"r") as f:
        for line in f:
                line = line[:-1] # remove newline
                if line.startswith(name):
                        oldName,pwHash=line.split(',')
                         
                        if oldName == name:
                                # salted password
                                if not check_password(name+pw,pwHash):
                                        print("Password does not match previous password! File NOT uploaded.")
                                        quit()
                                else:
                                        known_user = True
                                        break # password okay

# add user if unknown
if not known_user:
        with open (pwfile,"a") as f:
                # salt password
                f.write(name+","+get_hashed_password(name+pw)+'\n')
        # make folder for user
        os.mkdir(rosterFolder+name)

uploadFile = form['fileToUpload']
originalFilename = space_escape(uploadFile.filename)
filename = rosterFolder+name+'/'+rosterName+sentinel+originalFilename
with open(filename,"wb") as f:
     pdfFile = uploadFile.file
     while 1:
        chunk = pdfFile.read(4096)
        if not chunk: break
        f.write (chunk)

# attempt to extract the images
imageDir=filename[:-4] # strip .pdf for imageDir
p = Popen(['./extractImages.sh', filename, imageDir], stdin=PIPE, stdout=PIPE, stderr=PIPE)
output, err = p.communicate(b"input data that is passed to subprocess' stdin")
rc = p.returncode

if (output != ''):
        print("There may have been errors!")
        print (output+"<p>")
        print (err+"<p>")
#else:
#        print("File successfully uploaded!<p>")

with open('showRoster.html','r') as f:
        outputPage = f.read()

outputPage = outputPage.replace('name=;','name="'+name+'";');
folderName = rosterName+sentinel+originalFilename[:-4]
outputPage = outputPage.replace('imgFolder=;','imgFolder="'+folderName+'";');
print outputPage
#print("Your name: %s<p>" % space_unescape(name))
#print("Roster name: %s<p>" % space_unescape(rosterName))
#print("Filename: %s<p>" % space_unescape(originalFilename))

