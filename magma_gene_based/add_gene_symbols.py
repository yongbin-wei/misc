import pandas as pd
import sys

inputfile = sys.argv[1]
outputfile = sys.argv[2]

# load data
df = pd.read_table(inputfile, sep='\s+')

df_ref = pd.read_csv('/Users/yongbin/Documents/codes/magma/NCBI37.3.gene.loc', sep='\t', header=None)
df_ref = df_ref[[0,5]]
df_ref.columns=['GENE','SYMBOL']

df_out = pd.merge(df, df_ref, how='left', left_on='GENE', right_on='GENE')

# write table
df_out.to_csv(outputfile, index = False, sep = '\t')
print('Write to ', outputfile)
print(df_out.head())


