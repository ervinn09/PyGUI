# Intuitive User Interface for MATLAB Condition Table Creation

# Clone the repository
Download the files and folders manually one by one or clone the repository using:

**_git clone https://github.com/WafaaWardah/PyGUI-DB.git**

Open "define_fld.m" file and set the paths where noise files, clean signals are and where the degraded signals are going to be located.
A temporary folder is needed too.

Matlab has to be installed and "Signal processing toolbox" package.

# Define folders where the clean speech, noise, temporary and output files will be.
This has to be changed in "define_fld.m" script.


# How to bring the code to run

Be sure to have Python 3.9 or newer installed in your laptop

You need to have/install the following libraries:

- tkinter
- ttk, filedialog
- messagebox
- os
- random
- csv
- matlab.engine (Before importing this library, you need to install it using pip)

(Another way) Install anaconda, which will install all of the above automatically

# Run the code

First you have to make sure that the environment in which you are working on, is the one where you have installed all of the needed libraires. 

You can run the code in many different ways. 


One way is to open the terminal in the path of the repository and **run the command**: 

_1. python3 generate_condition_tables.py or python generate_condition_tables.py , ..._

The other method is to open imp.py in an IDE of your choice (for example Spyder), and change the environment to the one where the libraries are installed. 

_2. All that is left to do is to click on "Run"_

_3. Double click on generate_condition_tables.py file_

# Results
After creating the conditions and clicking "Save csv", the csv output file is created and it can be found in a folder that the user selected.
The degraded signals can be found on "Degraded Signals" folder, that the user create at the first steps.
