# Introduction
This repository contains tools for calibrating scrambling analysis from isotope ratio mass spectrometers (IRMS) for N<sub>2</sub>O isotopomers and the collection of data used in the publication by Smith et. al. in Rapid Communications of Mass Spectrometry showing the relationship between signal intensity and observed scrambling coefficient.

## Contents
- [Introduction](#Introduction)
  - [Contents](#Contents)
  - [Citation](#Citation)
- [N<sub>2</sub>O Scrambling Calibration](#N<sub>2</sub>O-Scrambling-Calibration)
- [Installation](#Installation)
-[Contents](#Contents)
  -[N2O_Calibration_Gas](#N2O_Calibration_Gas)
  -[IsoData](#IsoData)
  -[rMeasure](#rMeasure)
  -[invRM](#invRM)
  -[measureScrambling]9#measureScrambling)
  -[scrambleTrend](#scrambleTrend)
- [Workflow](#Workflow)
  - [Examples](#examples) 
  - [Importing Data](#Importing-Data-and-Creating-Objects)

## Citation
tbd

# N<sub>2</sub>O Scrambling Calibration


# Installation
## Requirements
Curve Fitting Toolbox (only for ```scrambleTrend```)  
Matlab R2018a or newer  

This package was only tested on R2018a. Some functions make work on previous versions, but there is no gaurantee. New versions are generally backwards compatible as new functions are added, but some may be depricated. 

# Contents
This package includes 8 files (6 functions and 2 object).  
- [N2O_calibration_gas](#N2O_calibration_gas)    
- [IsoData](#IsoData)  
- [measureScrambling](#measureScrambling)  
- [scrambleTrend](#scrambleTrend)  
- [rMeasure](#rMeasure)  
- [invRM](#invRM)  
- gauss  
- print_settings  


This is not an officially supported package with Matlab, so please download the files from [/src](src) folder and add them to your working directory. Files can be temporarily added by navigating to the folder with the files within Matlab, right-clicking the containing folder and selecting "Add to Path → Selected Folders". 

These files can be permanently added by including the path in your settings. Select the "HOME" tab in the ribbon, then in the "ENVIRONMENT" section click on "Set Path". A dialog box opens that shows the folders currently added to Matlab's directory. Select "Add Folder..." or "Add with Subfolders...", and in the opened dialog box navigate to where the files are stored and click "Select Folder". These should not always be available whenever Matlab is started.

## N2O_Calibration_Gas

```N2O_Calibration_Gas``` is an object that was made as a way to store reference gas information. This can later be called on by the ```IsoData``` to convert raw measurements to measured ratios. Creating the object for the reference gas(es) should be done carefully by manually entering the known contents of the reference gas. Simply enter the line:<br />
ref_name = N2O_Calibration_Gas($\delta$<sup>31</sup>, $\delta$<sup>45</sup>, $\delta$<sup>46</sup>)

Suppose your reference gas has the values $\delta$<sup>31</sup> = 4.01, $\delta$<sup>45</sup> = 2.7, $\delta$<sup>46</sup> = 25.2, this would be  
```ref_name = N2O_Calibration_Gas(4.01, 2.7, 25.2)```

It is assumed that the full isotopic description of the reference gas is known and can be derived from these three parameters, and the mass dependent fractionation of oxygen. The value for $\delta$<sup>31</sup> assumes an unscrambled ratio for <sup>31</sup>R = <sup>15</sup>R<sup>$\alpha$</sup> + <sup>17</sup>R. This object variable needs to be saved as a .mat file within the working directory of your project. Make sure that the file name is the same as the variable name.


## IsoData

The purpose of the IsoData object is to have a wrapper around raw IRMS measurements. Initializing an IsoData variable stores the raw measurements and provides the functions for calculating intensity ratios r, isotopic ratios R, and the isotopic deviation values $\delta$. An example script showing how ```IsoData``` is used can be found under [/Examples/IsoData_Example.m](/Examples/IsoData_Example.m).

### Initializing IsoData variable
Raw data from an IRMS is generally a table with two sets of columns for each faraday cup measurements; one set for reference gas and another for the sample. The reported values are a measure intensity. Continuous-flow measurments are reported as integrated voltage signals (e.g., mV-s) and dual-inlet measurements are reported as an average voltage (e.g., mV). A reference gas is measured before and after the sample gas. The two measurements are averaged to give a drift corrected measurement to compare against the sample gas measurement. This software uses the raw measurements to determine the scrambling coefficient. 

```IsoData``` variables require four inputs: raw reference & sample measurements (two matricies), reference gas ID (string), and a list of the masses measured (vector). The user will need to export data from their IRMS and save it in a format that is readily interpretted by matlab (e.g., text file .txt, or comma separated values .csv).

**Example IRMS Data**
| Measurement | Reference 1 | Reference 2 | Reference 3 | Sample 1 | Sample 2 | Sample 3 |
|:----:       | :----:      | :----:      | :----:      | :----:   | :----:   | :----:   |
| pre         | 1007        | 951         | 2250        |          |          |          |
| 1           | 1005        | 950         | 2249        | 1003     | 550      | 2302     |
| 2           | 1006        | 953         | 2251        | 1002     | 545      | 2298     |
| ...         | ...         | ...         | ...         | ...      | ...      | ...      |
| 10          | 998         | 952         | 2240        | 998      | 544      | 2301     |

First read in the data and separate the reference and sample measurements. From the example table above you should have two resulting tables:

Sample = 
| Sample 1 | Sample 2 | Sample 3 |
| :----:   | :----:   | :----:   |
| 1003     | 550      | 2302     |
| 1002     | 545      | 2298     |
| ...      | ...      | ...      |
| 998      | 544      | 2301     |

Reference =
| Reference 1 | Reference 2 | Reference 3 |
| :----:      | :----:      | :----:      |
| 1007        | 951         | 2250        |
| 1005        | 950         | 2249        |
| 1006        | 953         | 2251        |
| ...         | ...         | ...         |
| 998         | 952         | 2240        |

Suppose these measurements correspond to the m/z 44, 45 and 46 measurements of a sample against a reference gas named "Nov11_2022".

```measurement = IsoData(Sample, Reference, 'Nov11-2022', [44, 45, 46])```

An alternative method is to save the relevant information into a ```struct``` variable. This requires a very specific naming structure to work properly.<br />
```samp.sample = Sample;```<br />
```samp.reference = Reference;```<br />
```sampe.refID = 'Nov11-2022';```<br />
```samp.AMU = [44, 45, 46];```

The IsoData object is not set up for storying multiple datasets in a single instance. It is up to the user for how to best organize a collection of measurments in an associated experiment. In this work, different measured for a single experiment were consolidated into a matlab struct and saved as a single .mat file (e.g., [/Data/N2O.mat](/Data/N2O.mat)).

```IsoData``` is then initialized with:

```measurement = IsoData(samp);```

Instances of ```IsoData``` objects are checked to ensure that there is always one extra line of reference measurements than sample measurements, and that the associated ```N2O_calibration_gas``` object is saved in your directory. If you get the error "[ref name] does not exist...", double check that the variable is saved as a .mat file, and add it to your working directory. Alternatively, you can use the full file path as the reference name. For exmaple, the refID field would instead be ```'C:\My Documents\Matlab\Reference Gases\Nov11_2022.mat'```. A tradeoff with using the file path is that it will only work on a single machine where the file is stored.

### IsoData Functions
Each function takes an index argument and returns the measured value and the measurement uncertainty. The index is typically either 1 or 2. For m/z [44, 45, 46], index 1 yields the associatd 45 value and index 2 yields the associated 46 value. For m/z [30, 31, 32], 1 yields the 31 value, and 2 defaults to return a 0. r: calculates the intensity ratio based on the index called. R: calculates the isotopic ratio based on the intensity ratio r, and the known isotopic composition of the reference gas. delta: calculates the isotopic compositions deviation from the accepted international standard. Depends on R and hidden properties in the reference gas. These are called in either a functional form, or as a structure call:

Functional form:<br />
```r(measurement, 1)``` = <sup>45</sup>r<br />
```R(measurement, 2)``` = <sup>46</sup>R<br />
```delta(measurement, 1)``` = <sup>45</sup>$\delta$

Structure form:<br />
```measurement.r(1)``` = <sup>45</sup>r<br />
```measurement.R(2)``` = <sup>46</sup>R<br />
```measurement.delta(1)``` = <sup>45</sup>$\delta$

## rMeasure
Calculates <sup>15</sup>R<sub>$\alpha$</sub>, <sup>15</sup>R<sub>$\beta$</sub>, <sup>17</sup>R and <sup>18</sup>R using the formulation of  <sup>31</sup>R<sub>measured</sub>, <sup>45</sup>R, <sup>46</sup>R and mass-dependent fractionation of oxygen as defined in Kaiser et al 2003. Due to the non-linearity of the mass-dependent fractionation, <sup>17</sup>R is first calculated using the root-finding function ```fzero```. All other ratios are then calculated by algebraic substitutions. The four defining equations are as follows:

<sup>17</sup>R =  0.00937035 x (<sup>18</sup>R)<sup>0.516</sup>  

<sup>31</sup>R<sub>m</sub> = s<sup>15</sup>R<sub>$\beta$</sub> + 
(1 - s)<sup>15</sup>R<sub>$\alpha$</sub> + 
<sup>17</sup>R  

<sup>45</sup>R = <sup>15</sup>R<sub>$\alpha$</sub> + <sup>15</sup>R<sub>$\beta$</sub> + <sup>17</sup>R  

<sup>46</sup>R = <sup>15</sup>R<sub>$\alpha$</sub> x <sup>17</sup>R<sub>$\beta$</sub> + 
<sup>17</sup>R x (<sup>17</sup>R<sub>$\alpha$</sub> + 
<sup>17</sup>R<sub>$\beta$</sub>) + 
<sup>18</sup>R
 
Mass-dependent fractionation of oxygen gives a direct subsitution for <sup>18</sup>R in terms of <sup>17</sup>R. Using <sup>31</sup>R<sub>m</sub> and <sup>45</sup>R, <sup>15</sup>R<sub>$\alpha$</sub> and <sup>15</sup>R<sub>$\beta$</sub> can be solved in terms of the unknown <sup>17</sup>R:

<sup>15</sup>R<sub>$\alpha$</sub>(<sup>17</sup>R, <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R) 
= (1 - 2s)<sup>-1</sup> x (<sup>31</sup>R - s<sup>45</sup>R - (1-s)<sup>17</sup>R)  
<sup>15</sup>R<sub>$\beta$</sub>(<sup>17</sup>R, <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R) 
= (1 - 2s)<sup>-1</sup> x ((1-s)<sup>45</sup>R - <sup>31</sup>R - s<sup>17</sup>R)

This leads to an expression for <sup>46</sup>R that is given in terms of the measured quantities <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R and the unknown <sup>17</sup>R. The quantity for <sup>17</sup>R is then determined by applying the root-finding algorithm to the difference between the measured value of <sup>46</sup>R and the expression for <sup>46</sup>R that depends on <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R and <sup>17</sup>R:

<sup>46</sup>R - <sup>46</sup>R(<sup>17</sup>R, <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R) = 0

<sup>18</sup>R, <sup>15</sup>R<sub>$\alpha$</sub>, and <sup>15</sup>R<sub>$\beta$</sub> are then calculated with the now known <sup>17</sup>R.

Use the following syntax to call this equation:  
out = rMeasure([<sup>31</sup>R<sub>m</sub>, <sup>45</sup>R, <sup>46</sup>R], s)

The output is given as a 1 x 4 vector:  
out = [<sup>15</sup>R<sub>$\alpha$</sub>, <sup>15</sup>R<sub>$\beta$</sub>, <sup>17</sup>R, <sup>18</sup>R]

## invRM
This function inverses of ```rMeasure``` to give the expected measured values for <sup>31</sup>R<sub>m</sub>, <sup>45</sup>R, and <sup>46</sup>R. These means that ```rMeasure(invRM(input, s), s)``` = ```invRM(rMeasure(input, s), s)``` = ```input```. The output values are taken from the original formulation used for ```rMeasure```:

<sup>17</sup>R =  0.00937035 x (<sup>18</sup>R)<sup>0.516</sup>  
<sup>31</sup>R<sub>m</sub> = s<sup>15</sup>R<sub>$\beta$</sub> +
 (1 - s)<sup>15</sup>R<sub>$\alpha$</sub> +
 <sup>17</sup>R  
<sup>45</sup>R = <sup>15</sup>R<sub>$\alpha$</sub> + <sup>15</sup>R<sub>$\beta$</sub> + <sup>17</sup>R  
<sup>46</sup>R = <sup>15</sup>R<sub>$\alpha$</sub> x <sup>15</sup>R<sub>$\beta$</sub> +
 <sup>17</sup>R x (<sup>15</sup>R<sub>$\alpha$</sub> +
 <sup>15</sup>R<sub>$\beta$</sub>) +
 <sup>18</sup>R
 
 Use the following syntax to call this equation:  
out = invRM([<sup>15</sup>R<sub>$\alpha$</sub>, <sup>15</sup>R<sub>$\beta$</sub>, <sup>17</sup>R, <sup>18</sup>R], s)

The output is given as a 1 x 4 vector:  
out = [<sup>31</sup>R<sub>m</sub>, <sup>45</sup>R, <sup>46</sup>R]

A third optional input is available for manually inputting the isotopic ratios of the double-substituted species. This allows for the input:
invRM(R, s, [<sup>46</sup>R<sub>$\alpha\beta$</sub>, <sup>46</sup>R<sub>$\beta,17$</sub>, <sup>46</sup>R<sub>$\alpha,17$</sub>])

## measureScrambling
```measureScrambling``` uses a root finding algorithm to find the scrambling coefficient that explains discrepancies in the <sup>31</sup>r measurement. This requires complete knowledge of the sample (often spiked reference gas) and the reference gas. However, even achieving the <sup>31</sup>R<sub>measured</sub> for any sample from raw measurement requires knowledge of of the scrambling coefficient, which should not be assumed prior to making a measurement. From the raw measurements, we need to obtain the signal ratio <sup>31</sup>r for the sample and the reference gas. Dividing these two quantities yields the <sup>31</sup>rr value. More explicitly, this is given by:

<sup>31</sup>rr<sub>measure</sub> = <sup>31</sup>r<sub>sa</sub> / <sup>31</sup>r<sub>ref</sub>

This eliminates the differences in detector sensitivity of the m/z 31 and m/z 30 measurements. This is equivalent to the ratio of the actual isotopic ratios of the two gases when considering the influence of scrambling:

<sup>31</sup>rr<sub>theory</sub> = <sup>31</sup>R<sub>sa,m</sub> / <sup>31</sup>R<sub>ref,m</sub>

The formulation for measured <sup>31</sup>R is given above in the description of ```rMeasure```. Since knowledge of the individual isotopic ratios is required prior to this calculation, <sup>31</sup>rr<sub>theory</sub> is only a function of the scrambling cofficient ```s```. Thus we can find the ```s``` that explains the data by finding the value that will give a zero difference between <sup>31</sup>rr<sub>theory</sub> and <sup>31</sup>rr<sub>measure</sub>. This function accomplishes this by defining the error function <sup>31</sup>rr<sub>measure</sub> - <sup>31</sup>rr<sub>theory</sub> as an anonymous function and using the ```fzero``` function in the domain of [0, 1]:

```fzero(errorFunction, [0, 1])```

This function has 3 required inputs, and 1 optional input. The first two is the individual ratios of the sample and reference gas in an 1x4 array. They must be in the order:

[<sup>15</sup>R<sub>$\alpha$</sub>, <sup>15</sup>R<sub>$\beta$</sub>, <sup>17</sup>R,  <sup>18</sup>R]

The third input can be a single value, or a 1xn array of the <sup>31</sup>rr<sub>measure</sub> values. The input size determines the output size as the function loops over each input assuming the same defined sample and reference input. The 4th optional input is then if the user wishes to specify isotopomers of the double-substituted molecules. If this is not included, a stochastic distribution is assumed and they will be calculated from the singles. This input is a 1x3 array given in the following order:

[<sup>15</sup>R<sub>$\alpha$</sub> x <sup>15</sup>R<sub>$\beta$</sub>,
 <sup>17</sup>R<sub>$\alpha$</sub> x <sup>17</sup>R,
 <sup>17</sup>R<sub>$\beta$</sub> x <sup>17</sup>R]

## scrambleTrend
This function calculates an s-curve best fit line on the input ```x``` and ```y``` data. It is used to determine how scrambling varies with a given input parameter (i.e., signal intensity). This function uses the aggregate of Scrambling values determined from raw calibration measurements that were analyzed with the measureScrambling function. This function uses the curve fitting toolbox to solve the following equation for ```a```, ```b```, and ```c```:

y = (a*x+b) / (1+c*(a*x+b))

There are four outputs given in the order of:  
[```fitresult```, ```gof```, ```p```, ```limits```]

```fitresult``` is a matlab ```cfit``` object that resulted from the curve fit. This contains the results for ```a```, ```b```, and ```c``` and can be used to obtain uncertainties of the results.  
```gof``` means "goodness of fit" and is also generated by the curve fit. It is a ```struct``` that contains common statistical results.  
```p``` is the p-value for validating if the s-curve trend persists with the given data. See below for more details.  
```limits``` are the minimum and maximum possible values for y within the positive region.

The p-value is determined from the uncertainty of the fit results for the parameter ```a```. Since ```x``` is always multiplied by ```a```, a zero value would indicate that y does not depend on ```a``` at all and is better described by a constant. Thus the null hypothesis is defined as ```a``` being 0 or negative. The 1$\sigma$ deviation of ```a``` is determined by calculating the 68% confidence interval from ```fitresult```. Knowing that the distribution has a mean value of ```a```, the probability is then integrated from -∞ to 0. This result is the p-value.

# Workflow
The workflow described here only describes the analysis process for determining the scrambling coefficient that is later used to determine isotopomer ratios for an N<sub>2</sub>O sample. Measurement techniques may vary from machine to machine. 

Processing data is a linear process that can be scripted (see examples). The general process is: import data → calculate scrambling → evaluate trend.

## Importing Data and Creating Objects
This code uses defined objects as wrappers for data. This ensures consistency in code execution and some convenience for easily extracting properties from raw data. The two defined data objects are ```N2O_Calibration_Gas``` and ```IsoData```.
