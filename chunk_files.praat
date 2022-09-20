#Cuts up a large sound file into smaller chunks using an existing tier on an associated TextGrid file.
#The Renamed file prefix is a string that the user can add to all extracted intervals for the particular sound file.
#The tier number reflects the tier containing the string which will be used for the main file name. 
#The assumption of this script is that you have run create_chunk_tgs.R in R for each of your sound files.

#This script is useful for either experimental purposes (e.g. cutting up tokens into smaller files which are more
#manageable) or for corpus/fieldwork linguistic purposes (e.g. you export an ELAN file to Praat and then extract
#words of a particular type). 

#Copyright Christian DiCanio, SUNY Buffalo, 2016, 2020.
#Hacked by Hannah White 2022.

form Extract smaller files from large file
	sentence Directory_name: /Users/hannahwhite/Downloads/demo/
	sentence Renamed_file_prefix: chunk
	positive Tier_number: 1
endform


Create Strings as file list... list 'directory_name$'*.wav
number_of_files = Get number of strings

for i from 1 to number_of_files
	select Strings list
	current_sound$ = Get string... 'i'
	Read from file... 'directory_name$''current_sound$'
	soundID = selected("Sound")
	basename$ = current_sound$ - ".wav"
	Read from file... 'directory_name$''basename$'.TextGrid
	textGridID = selected("TextGrid")
	select 'textGridID'
	intvl_length = Get number of intervals: tier_number

	for j from 1 to intvl_length
		lab$ = Get label of interval: tier_number, j
		time = Get starting point: tier_number, j
		index$ = string$(time)
		
		if lab$ = ""
				#do nothing
		else 
				start = Get starting point: tier_number, j
				end = Get end point: tier_number, j
				select 'textGridID'
				tg_chunk = Extract part: start, end, "no"
				select 'soundID'
				Extract part... start end rectangular 1 no
				Write to WAV file... 'directory_name$''renamed_file_prefix$'_'lab$'.wav
		endif
		select 'textGridID'
	endfor
	select all
	minus Strings list
	Remove
endfor
select all
Remove
print All files have been segmented!  Have a nice day!