import pandas as pd
import os
import numpy as np
from IRMS import MSMeas

#Root Directory
folder = 'G:/Shared drives/Rice Lab Data/N2O/Scrambling/Raw Data/'
files = []
data = {'NO': {}, 'N2O': {}}
for i in os.listdir(folder):
    if i[0:3] == 'Mar': #Only files that start with Mar have valid raw data
        extentionIdx = i.find('.')
        sampleID = i[extentionIdx-2:extentionIdx]
        data['NO'][sampleID]=[]
        data['N2O'][sampleID] = []
        fname = folder+i
        xl = pd.ExcelFile(fname) #Read in the Excel file
        for j,sname in enumerate(xl.sheet_names):
            if j>2: #3rd sheet and beyond contains data
                sht = pd.read_excel(fname,sheet_name=sname)
                cols = sht.columns
                if sname[0:2] == 'NO':
                    breaks = [i for i, x in enumerate(sht[cols[0]]) if x == 'Average']
                elif sname[0:2] == 'N2':
                    breaks = [i for i,x in enumerate(sht[cols[0]].isnull()) if x]
                    breaks.append(sht[cols[0]].__len__()-1)
                breaks.insert(0,-2)
                breaks = np.array(breaks)
                refStart = breaks[0:-1]+2
                dataStart = refStart+1
                dataStop = breaks[1:]-1
                for idx,stp in enumerate(dataStop):
                    ref = sht[cols[4:7]][refStart[idx]:stp].to_numpy()
                    samp = sht[cols[1:4]][dataStart[idx]:stp].to_numpy()
                    if isinstance(ref[0, 0],float):
                        if not(np.isnan(ref[0,0])):
                            ## ref values are based on the praxair measurements of d45N2O = 2.71‰, d46N2O = 40.55‰ (vs AIR & VSMOW), d31NO = 4.07‰ (vs N2O from VSMOW & Air)
                            if sname[0:2]=='NO':
                                data['NO'][sampleID].append(MSMeas(sample=samp, reference=ref, AMU=[30,31,32], molecule='NO', refR = [1,0.004065441150123605,0],refID='praxair1'))
                            elif sname[0:2]=='N2':
                                data['N2O'][sampleID].append(MSMeas(sample=samp, reference=ref, AMU=[44,45,46], molecule='N2O', refR = [1,0.007708354842497704,0.002155107548219395],refID='praxair1'))


    db = pd.DataFrame.from_dict(data)
    db.to_pickle(folder+'dataframe.pkl')