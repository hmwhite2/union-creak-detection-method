##  text grid maker.praat
## Originally created by the excellent Katherine Crosswhite
## Script modified by Mark Antoniou and Zhenghan Qi
## Script further modified by Hannah White to remove opening files in editor.

## What does it do?
## This script opens all files in a directory. It creates a TextGrid for each sound file and saves them with the sound files.

##  Leaving the "Word" field blank will open all sound files in a directory. By specifying a Word, you can open only those files that begin with a particular sequence of characters. For example, only tokens whose filenames begin with ba.

# The following four lines will create a dialog box, asking for the directory location you want to use. The two variables, Directory" and "Word" will be used later in the script, where they are referred to as "directory$" and "word$", the dollar sign indicating that they are both string variables.

form Enter directory and search string
# Be sure not to forget the slash (Windows: backslash, OSX: forward slash)  at the end of the directory name.
	sentence Directory /Users/hannahwhite/OneDrive - Macquarie University/PhD/Study_3/wav_files/female_wav/
	sentence Word
	sentence Filetype wav
endform

Create Strings as file list... list 'directory$'/*.wav
numberOfFiles = Get number of strings
for ifile to numberOfFiles
   Create Strings as file list... list 'directory$'/*.wav
   select Strings list
   fileName$ = Get string... ifile
   Read from file... 'directory$'/'fileName$'

# A variable called "object_name$" will have the name of the sound object.  This is equivalent to the filename minus the extension. This will be useful for referring to the sound object later.
   object_name$ = selected$ ("Sound")

# Now create a TextGrid for the current sound file. It will have only one tier named "segments".  You can have multiple tiers, each with its own name.  For example, I could've made three tiers by saying To TextGrid... "utterances words segments".
   To TextGrid... "segments"

# Save the textgrid, giving it the same filename as the sound file, and the extension ".TextGrid". 
   Write to text file... 'directory$'/'object_name$'.TextGrid

#    End the loop, and go on to the next file. To conserve memory, first remove the objects that we are through with. I like to do this by selecting all the objects in the list, then deselecting any we will still be using, such as the list of filenames.
   select all
   minus Strings list
   Remove

# This specifies the end of the loop.
endfor