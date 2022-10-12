# Union method procedure
The following describes how to carry out the Union method to detect creaky voice from the publication: 

White, H., Penney, J., Gibson, A., Szakay, A. & Cox, F. (2022). Evaluating automatic creaky voice detection methods. 
    Journal of the Acoustical Society of America, 152(3).
    
The researcher must decide whether they are going to conduct an analysis over all data (processing raw sound files through methods) or over sonorants only
(vowels, nasals, glides, liquids)(requiring speech to be orthographically transcribed and processed through a forced aligner).
The researcher must also decide whether they are going to use the default settings of CD (no threshold sweep) or find the optimal threshold for CD for 
their data (requiring a subset of data to be manually annotated for creak and a threshold sweep to be performed on this subset).

The method requires researchers to use [Praat](https://www.fon.hum.uva.nl/praat/), [R](https://www.R-project.org/) and [MATLAB](https://au.mathworks.com/products/matlab.html) for processing.

The demo folder contains two example wav files which have been forced aligned (corrected tier is "SON") and annotated for creaky voice in the accompanying TextGrids. These can be used to demonstrate the Union method.

## To begin:
1. Resample sound files to 16000Hz
2. Install REAPER (either [MacREAPER](https://kjdallaston.com/projects/) or [REAPER](https://github.com/google/REAPER/)) and download CD_method folder (adapted from [Kane et al.](https://github.com/jckane/Voice_Analysis_Toolkit/))
3. Get durations of sound files using get_durations.praat script.
4. **If you are doing a SONORANTS ONLY analysis:** You will need to have sound files orthographically transcribed and process them through a forced aligner. [This](https://clarin.phonetik.uni-muenchen.de/BASWebServices/interface/Pipeline) is the forced aligner used in White et al. 2022. Create phoneme csv files using the create_phoneme_files.R in R

## AM method:
1. Chunk files into 20s intervals for REAPER (this is for quicker processing). This can be done using the create_chunk_tgs.R script to get TextGrids with boundaries every 20s + remainder. Then the chunk_files.praat script can be used to extract chunked sound files
2. Run chunked files through REAPER
3. Create concatenated and complete Pitch Mark csv files using the create_pm_files.R script in R
4. Get AM output:

    a. **If you are doing an ALL DATA analysis:** Get AM output by running get_am_output_alldata.R script in R
   
    b. **If you are doing a SONORANTS ONLY analysis:** Get AM output by running get_am_output_sonorants.R script in R

## CD method:
(You may want to check that CD is measuring H2-H1 for your data - we've had a couple of instances where this has not been the case.)
- **If you are NOT doing a threshold sweep:**

    1. Open CD_method folder in MATLAB and open getCreakDetectorOutput.m file. Change your out/in directories on lines 12 and 36. To run the default settings for CD, make sure the thresh on line 17 is set to 0.3:0.01:0.3. Run this script.
    2. Run get_cd_output.R in R to get CD csv files in the correct format for union method

- **If you ARE doing a threshold sweep:**

    1. Manually annotate a subset of your data for creaky voice
    2. Open CD_file folder in MATLAB and open getCreakDetectorOutput.m file. Change your out/in directories on lines 12 and 36 and set values for your threshold sweep on line 17 (1st value = first threshold; 2nd value = increment to sweep by; 3rd value = final threshold). Run this script.
    3. Conduct threshold sweep:
   
        a. **If you are doing an ALL DATA analysis:** Run threshold_sweep_alldata.R in R to visualise threshold sweep and get optimal threshold
      
        b. **If you are doing a SONORANTS ONLY analysis:** Run threshold_sweep_sonorants.R in R to visualise threshold sweep and get optimal threshold
   
    4. Run entire sound files through CD (using getCreakDetectorOutput.m file) with threshold set to optimal threshold (in line 17, set values as follows: 1st value = opt threshold; 2nd value = 0.01; 3rd value = opt threshold)
    5. Run get_cd_output.R in R to get CD csv files in the correct format for union method

## Union method:
1. Create file with Union method:

    a. **If you are doing an ALL DATA analysis:** Run get_union_method_alldata.R in R
   
    b. **If you are doing a SONORANTS ONLY analysis:** Run get_union_method_sonorants.R in R
