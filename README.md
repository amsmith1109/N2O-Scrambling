# Introduction
This repository contains tools for calibrating scrambling analysis from isotope ratio mass spectrometers (IRMS) for N<sub>2</sub>O isotopomers and the collection of data used in the publication by Smith et. al. in Rapid Communications of Mass Spectrometry showing the relationship between signal intensity and observed scrambling coefficient.

## Contents
- [Introduction](#Introduction)
  - [Contents](#Contents)
  - [Citation](#Citation)
- [N<sub>2</sub>O Scrambling Calibration](#N<sub>2</sub>O-Scrambling-Calibration)
- [Installation](#Installation)
- [Workflow](#Workflow)
  - [Examples](#examples) 
  - [Importing Data](#Importing-Data-and-Creating-Objects)

## Citation
tbd

# N<sub>2</sub>O Scrambling Calibration



# Installation
tbd

# Workflow
The workflow described here only describes the analysis process for determining the scrambling coefficient that is later used to determine isotopomer ratios for an N<sub>2</sub>O sample. Measurement techniques may vary from machine to machine. 

Processing data is a linear process that can be scripted (see examples). The general process is: import data → calculate scrambling → evaluate trend.

## Importing Data and Creating Objects
This code uses defined objects as wrappers for data. This ensures consistency in code execution and some convenience for easily extracting properties from raw data. The two defined data objects are ```N2O_Calibration_Gas``` and ```IsoData```.

### N2O_Calibration_Gas

Creating the object for the reference gas(es) should be done carefully by manually entering the known contents of the reference gas. Simply enter the line:<br />
``` ref_name = N2O_Calibration_Gas```<br />
```ref_name.delta31 = delta_31_value```<br />
```ref_name.delta45 = delta_45_value```<br />
```ref_name.delta46 = delta_46_value```

It is assumed that the full isotopic description of the reference gas is known and can be derived from these three parameters, and the mass dependent fractionation of oxygen. The value for $\delta$<sup>31</sup> assumes an unscrambled ratio for <sup>31</sup>R = <sup>15</sup>R<sup>$\alpha$</sup> + <sup>17</sup>R. This object variable needs to be saved as a .m file within the working directory of your project. The saved file will later be accessed by the related ```IsoData``` variable.

### IsoData

The purpose of the IsoData object is to have a wrapper around raw IRMS measurements. Initializing an IsoData variable stores the raw measurements and provides the functions for calculating intensity ratios r, isotopic ratios R, and the isotopic deviation values $\delta.

## Initializing IsoData variable
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

```IsoData``` is then initialized with:

```measurement = IsoData(samp);```

## IsoData Functions
Each function takes an index argument and returns the measured value and the measurement uncertainty. The index is typically either 1 or 2. For m/z [44, 45, 46], 1 yields the 45 value and 2 yields the 46 value. For m/z [30, 31, 32], 1 yields the 31 value, and 2 defaults to return a 0. r: calculates the intensity ratio based on the index called. R: calculates the isotopic ratio based on the intensity ratio r, and the known isotopic composition of the reference gas. delta: calculates the isotopic compositions deviation from the accepted international standard. Depends on R and hidden properties in the reference gas. These are called in either a functional form, or as a structure call:

Functional form:<br />
```r(measurement, 1)```<br />
```R(measurement, 1)```<br />
```delta(measurement, 1)```

Structure form:<br />
```measurement.r(1)```<br />
```measurement.R(1)```<br />
```measurement.delta(1)```

