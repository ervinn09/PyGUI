Database Generation

This code can be used to generate speech quality datasets with different distortions (six different codecs, packet loss, background noise, white noise, filters, clipping) and their combinations. By using the Matlab parallel toolbox, large datasets can be generated quickly. The code only runs on Windows as it relies on ITU, ETSI and Opus exectuables of the codecs and the ITU STL Toolbox. The Opus exectuables have been modified to allow the application of packet loss patterns from the ITU tool.

The generation is run with "runDatabaseGeneration.m" in 3 steps.

1. ---- Condition Table ------
A condition table is created. Each row represents one condition that should be generated for x files. Each distortion is set either on or off via a  parameter, where 'x' means on and anything else is off. Each distortion has a second input that determines the distortion strength. This table could also be manually created (e.g. with Excel). There are two examples provided to generate the table with Matlab "makeConditionTable_NISQA_TEST_P501" and "makeConditionTable_NISQA_TRAIN_SIM".

A description of the conditon table columns is given here:

    filter: either 'highpass', 'lowpass', 'bandpass'
    bp_high: high cut off frequency of bandpass and lowpass
    bp_low: low cut off frequency of bandpass and highpass

    arb_filter: if 'x' apply arbitrary frequency filter

    timeclipping: if 'x' apply timeclipping with swissqual tool "InsertFrameLosses.exe" (zero insertion)
    tc_fer: sets frame error rate of timeclipping (in %)
    tc_nburst: burstyness (max nr. of consecutive lost frames)

    wbgn: if 'x' applies white noise
    wbgn_snr: SNR of white noise

    p50mnru: if 'x' applies MNRU noise
    p50_q: Q distortion parameter of MNRU noise

    asl_in: if 'x' active speech level is set before applying any degredation, if 'no' asl level will be unchanged, if anything else level will be set to -26dbo
    asl_in_level: level in dbo

    asl_out: if 'x' active speech level is set after all degredations have been applied
    asl_out_level: level in dbo

    clipping: if 'x' applies clipping 
    cl_th: clipping threshold, signal range is -1 and 1. all samples higher than abs(cl_th) will be set to cl_th: x(x>abs(cl_th)) = cl_th

    bgn: if 'x' applies random background noise from noise folder. if 'bgn_file' applies background noise file from bgn_file
    bgn_file: filename of noise file, placed in noise folder
    bgn_snr: SNR of background noise

    codec1: if 'skip' no codec is applied, otherwise either 'amrnb', 'amrwb', 'evs', 'opus', 'g711', 'g722'
    bMode1: bitrate mode of codec (bitrate in case of opus as it has no modes)
    plcMode1: applies packet loss if either 'random' or 'bursty', or no loss with 'noloss'. The packet loss patterns can also be stored in a .csv file (uncomment line 213 in "generateDegradedSignal.m")
    FER1: frame error rate (as rate, not %)

    codec2: can be used to apply second codec (transcoding, codec tandem) 
    bMode2: 
    plcMode2: 
    FER2: 

    codec3: can be used to apply third codec (transcoding, codec triple tandem) 
    bMode3: 
    plcMode3: 
    FER3: 

    dist_post_codec: if 'x' distortions (noise clipping, filters) will be applied after coding


2. ---- Filelist Table ------
The second table contains a column 'con' and 'filename' that defines which and how many files should be processed for each of the conditions. The example processes all four given speech samples in the "ref" folder for each condition.

3. ---- Applying distortions ------
In the third step each file is processed with its distortion and saved in the output folder. To run the code without parallel loop (e.g. for debugging) replace the "parfor" loop with a "for" loop.


- Gabriel Mittag, 2021


------

This version of the Database Generation Tool is fixed so that errors are no longer occurring when the user of the script is not named "Gabriel".

- Thilo Michael, 2023