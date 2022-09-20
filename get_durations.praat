### This script gets duration info of each .wav file in a directory and extracts 
### into a txt file.

### written by Hannah White 2022 with help from https://www.eleanorchodroff.com/tutorial/PraatScripting.pdf

dir$ = "/Users/hannahwhite/Downloads/demo/"
outfile$ = "/Users/hannahwhite/Downloads/demo/durations.txt"

Create Strings as file list: "files", dir$ + "*.wav"
nFiles = Get number of strings

for i from 1 to nFiles
	selectObject: "Strings files"
	filename$ = Get string: i
	basename$ = filename$ - ".wav"
	Read from file: dir$ + basename$ + ".wav"
	dur = Get total duration
	appendFileLine: outfile$, filename$, tab$, dur
	Remove
endfor

print All files have been processed!