import sys
import pandas as pd
import os

inputfile = sys.argv[1]
outputfile = sys.argv[2]

if os.path.exists(inputfile):
    print('Read ' + inputfile + '...')
else:
    print(inputfile + ' does not exist')
    exit()

# load data
df = pd.read_table(inputfile)
print(df.head())

df_out = df[['CHR','SNP','BP','A1','A2']]
df_out.insert(2, 'MP', 0)

# write table
df_out.to_csv(outputfile, index = False, header = False, sep = '\t')
print('Write to ', outputfile)
