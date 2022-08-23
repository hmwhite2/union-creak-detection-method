#### Union method procedure #####
The following describes how to carry out the Union method to detect creaky voice from the publication: 

White, H., Penney, J., Gibson, A., Szakay, A. & Cox, F. (2022). Evaluating automatic creaky voice detection methods. 
    The Journal of the Acoustical Society of America
    
The researcher must decide whether they are going to conduct an analysis over all data (processing raw sound files through methods) or over sonorants only
(requiring speech to be orthographically transcribed and processed through a forced aligner).
The researcher must also decide whether they are going to use the default settings of CD (no threshold sweep) or find the optimal threshold for CD for 
their data (requiring a subset of data to be manually annotated for creak and a threshold sweep to be performed on this subset).

## To begin:
1.	Resample sound files to 16000Hz
2.	Install REAPER (either MacREAPER: https://kjdallaston.com/projects/ or REAPER: https://github.com/google/REAPER) and download CD_method folder 
    (adapted from https://github.com/jckane/Voice_Analysis_Toolkit)
4.	If you are doing a SONORANTS ONLY analysis: Create phoneme csv file using the create_phoneme_files.R in R


## AM method:
1.	Chunk file into 20s intervals for REAPER (this is for quicker processing)
2.	Run chunked files through REAPER
3.	Create concatenated and complete Pitch Mark csv files using the create_pm_files.R script in R
4.	Get AM output:
	      a. If you are doing an ALL DATA analysis: Get AM output by running get_am_output_alldata.R script in R
        b. If you are doing a SONORANTS ONLY analysis: Get AM output by running get_am_output_sonorants.R script in R

## CD method:
•	If you are NOT doing a threshold sweep: 
        1.  Open CD_method folder in MATLAB and open getCreakDetectorOutput.m file. Change your out/in directories on lines 12 and 36. To run the 
        default settings for CD, make sure the thresh on line 17 is set to 0.3:0.01:0.3. Run this script. 
•	If you ARE doing a threshold sweep: 
        1.	Manually annotate a subset of your data for creaky voice.
        2.	Open CD folder in MATLAB and open getCreakDetectorOutput.m file. Change your out/in directories on lines 12 and 36 and set values for 
            your threshold sweep as follows on line 17 (1st value = first threshold; 2nd value = increment to sweep by; 3rd value = final threshold). 
            Run this script.
        3.	Conduct threshold sweep
                a.	If you are doing an ALL DATA analysis: Run threshold_sweep_alldata.R in R to visualise threshold sweep and get optimal threshold
                b.	If you are doing a SONORANTS ONLY analysis: Run threshold_sweep_sonorants.R in R to visualise threshold sweep and get optimal 
                    threshold
        4.	Run entire sound files through CD with threshold set to optimal threshold (in line 17 of getCreakDetectorOutput.m, set values as 
            follows: 1st value = opt threshold; 2nd value = 0.01; 3rd value = opt threshold)
        5.	Run get_cd_output.R in R to get CD csv files in the correct format for union method.

## Union method:
1.	Create file with Union method:
        a.	If you are doing an ALL DATA analysis: Run get_union_method_alldata.R in R.
        b.	If you are doing a SONORANTS ONLY analysis: Run get_union_method_sonorants.R in R.
