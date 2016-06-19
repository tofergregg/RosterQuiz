#!/usr/bin/env python

import sys
import os

if len(sys.argv) != 3:
        print("Usage:")
        print("\tparseNames.py filename.pdf img_folder")
        quit()

with open(sys.argv[1],"r") as f:
        rawText = f.read()

textLines = rawText.split("\n")

# only look at lines that start with 11 spaces or blank lines
newText1 = [x[11:] for x in textLines if (x.startswith('           ') 
                                         and x[11].isalpha()) or len(x)==0]

# read each line until we find two spaces, at which point we truncate
newText1 = [x[:x.find("  ")] for x in newText1]

#for line in newText1:
#        print(line)

# All students will be in the form "something1, something2",
# but there could be two lines that make this up.
# However, there will be a blank line between entries, so if
# there isn't a blank line, then the two should be concatenated
# HOWEVER, there is the unlikely case where two students might not
# have a blank line (double majors...)
# Our final fall-back will be to see if both have a comma, and if so,
# don't put them on the same line, as there will always only be one
# comma per student (hopefully...)

newText2 = []
foundBlank = True

for idx,line in enumerate(newText1):
        if len(line) == 0:
                foundBlank = True
                # now skip
        else:
                if foundBlank: # will always add a new entry if blank was just found 
                        newText2.append(line)
                        foundBlank = False
                else:
                        # make sure both don't have commas 
                        if ',' not in newText2[-1] or ',' not in line:
                                # if prev last character is a comma, put a space
                                # or, if the last character and the first character
                                # are letters, put a space
                                if ((newText2[-1][-1] == ',')
                                   or (newText2[-1][-1].isalpha() and line[0].isalpha())):
                                        newText2[-1]+=' '

                                newText2[-1]+=line
                        else:
                                newText2.append(line)

# remove space after comma and replace with underscore (but leave other spaces)
names = [x.replace(', ','_') for x in newText2]

# now replace names

img_folder = sys.argv[2]

# names will have the form image-000.jpg and the number will increment by 1
# If all goes well, we will have the same number of files as names
jpgs = os.listdir(img_folder)
jpgs = [x for x in jpgs if ".jpg" in x]

if len(jpgs) != len(names):
        print("Names count and jpg count differ! Quitting!")
        print("Names:%d,Jpegs:%d" % (len(names),len(jpgs)))
        for idx,name in enumerate(names):
                print str(idx+1)+" "+name+"<p>"
        quit()

# okay, we can do the renaming
for idx,name in enumerate(names):
       jpg_number = str(idx).zfill(3)
       jpg_name = img_folder+'/image-'+jpg_number+'.jpg'
       new_name = img_folder+'/'+name+'.jpg'
       os.rename(jpg_name,new_name)

