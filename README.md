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

Creating the object for the reference gas(es) should be done carefully by manually entering the known contents of the reference gas. Simply enter the line:

``` ref_name = N2O_Calibration_Gas```

```ref_name.delta31 = delta_31_value```

```ref_name.delta45 = delta_45_value```

```ref_name.delta46 = delta_46_value```

### IsoData
Raw data from an IRMS is generally a table with two sets of columns for each faraday cup measurements; one set for reference gas and another for the sample. The reported values are a measure intensity. Continuous-flow measurments are reported as integrated voltage signals (e.g., mV-s) and dual-inlet measurements are reported as an average voltage (e.g., mV). A reference gas is measured before and after the sample gas. The two measurements are averaged to give a drift corrected measurement to compare against the sample gas measurement. This package uses the raw measurements to determine the scrambling coefficient. 

The user will need to export data from their IRMS and save it in a format that is readily interpretted by matlab (e.g., text file .txt, or comma separated values .csv).

**Example IRMS Data**
| Measurement | Reference 1 | Reference 2 | Reference 3 | Sample 1 | Sample 2 | Sample 3 |
|:----:       | :----:      | :----:      | :----:      | :----:   | :----:   | :----:   |
| pre         | 1007        | 951         | 2250        |          |          |          |
| 1           | 1005        | 950         | 2249        | 1003     | 550      | 2302     |
| 2           | 1006        | 953         | 2251        | 1002     | 545      | 2298     |
| ...         | ...         | ...         | ...         | ...      | ...      | ...      |
| 10          | 998         | 952         | 2240        | 998      | 544      | 2301     |

First read in the data and separate the reference and sample measurements. You should have something like:

Sample = 
| Sample 1 | Sample 2 | Sample 3 |
| :----:   | :----:   | :----:   |
| 1003     | 550      | 2302     |
| 1002     | 545      | 2298     |
| ...      | ...      | ...      |
| 998      | 544      | 2301     |


