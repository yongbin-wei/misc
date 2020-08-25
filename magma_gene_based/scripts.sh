#!/bin/bash

datapath='/Volumes/tidis/sumstats'
reffile='/Users/yongbin/Documents/codes/magma/g1000_eur'
pheno=4
# 1. scz_con 2. bd_con 3. ad_con 4. asd_con

# ############### schizophrenia #################
if (($pheno==1))
then
  echo ">> Run SCZ_CON …"
  phenoname="scz_con"
  sumstat='sczvscont-sumstat.gz'
  sumstatname="${sumstat%.*}"

  echo "Gunzip ${sumstat} ..."
  gunzip ${datapath}/${sumstat}
  echo "Done. ${sumstatname}"

  python3 make_bim.py ${datapath}/${sumstatname} ./results/${phenoname}.bim

  # annotation
  echo ">> MAGMA gene annotation starts ..."
  magma --annotate --snp-loc ./results/${phenoname}.bim --gene-loc /Users/yongbin/Documents/codes/magma/NCBI37.3.gene.loc --out ./results/${phenoname}

  # gene-based analysis
  echo ">> MAGMA gene-based analysis starts ..."
  N=87491
  magma --bfile ${reffile} --gene-annot ./results/${phenoname}.genes.annot --pval ${datapath}/${sumstatname} N=${N} --out ./results/${phenoname}

  # add gene_symbols
  python3 add_gene_symbols.py ./results/${phenoname}.genes.out ./results/${phenoname}.genes.out.txt 
  
  echo "Gzip ${datapath}/${sumstatname}"
  gzip ${datapath}/${sumstatname}
fi


# ############### BD #################
if (($pheno==2))
then
  echo ">> Run BD_CON …"
  phenoname="bd_con"
  sumstat='BDvsCONT.sumstats.gz'
  sumstatname="${sumstat%.*}"
  N=74194

  echo "Gunzip ${sumstat} ..."
  gunzip ${datapath}/${sumstat}
  echo "Done. ${sumstatname}"

  python3 make_bim.py ${datapath}/${sumstatname} ./results/${phenoname}.bim

  # annotation
  echo ">> MAGMA gene annotation starts ..."
  magma --annotate --snp-loc ./results/${phenoname}.bim --gene-loc /Users/yongbin/Documents/codes/magma/NCBI37.3.gene.loc --out ./results/${phenoname}

  # gene-based analysis
  echo ">> MAGMA gene-based analysis starts ..."
  magma --bfile ${reffile} --gene-annot ./results/${phenoname}.genes.annot --pval ${datapath}/${sumstatname} N=${N} --out ./results/${phenoname}

  # add gene_symbols
  python3 add_gene_symbols.py ./results/${phenoname}.genes.out ./results/${phenoname}.genes.out.txt 
  
  echo "Gzip ${datapath}/${sumstatname}"
  gzip ${datapath}/${sumstatname}
fi


# ############### AD #################
if (($pheno==3))
then
  echo ">> Run AD_CON …"
  phenoname="ad_con"
  sumstat='AD_sumstats_Jansenetal_2019sept.txt.gz'
  sumstatname="${sumstat%.*}"
  N=455258

  echo "Gunzip ${sumstat} ..."
  gunzip ${datapath}/${sumstat}
  echo "Done. ${sumstatname}"

  python3 make_bim.py ${datapath}/${sumstatname} ./results/${phenoname}.bim

  # annotation
  echo ">> MAGMA gene annotation starts ..."
  magma --annotate --snp-loc ./results/${phenoname}.bim --gene-loc /Users/yongbin/Documents/codes/magma/NCBI37.3.gene.loc --out ./results/${phenoname}

  # gene-based analysis
  echo ">> MAGMA gene-based analysis starts ..."
  magma --bfile ${reffile} --gene-annot ./results/${phenoname}.genes.annot --pval ${datapath}/${sumstatname} N=${N} --out ./results/${phenoname}

  # add gene_symbols
  python3 add_gene_symbols.py ./results/${phenoname}.genes.out ./results/${phenoname}.genes.out.txt 
  
  echo "Gzip ${datapath}/${sumstatname}"
  gzip ${datapath}/${sumstatname}
fi


# ############### ASD #################
if (($pheno==4))
then
  echo ">> Run ASD_CON …"
  phenoname="asd_con"
  sumstat='iPSYCH-PGC_ASD_Nov2017.gz'
  sumstatname="${sumstat%.*}"
  N=46350
  
  echo "Gunzip ${sumstat} ..."
  gunzip ${datapath}/${sumstat}
  echo "Done. ${sumstatname}"

  python3 make_bim.py ${datapath}/${sumstatname} ./results/${phenoname}.bim

  # annotation
  echo ">> MAGMA gene annotation starts ..."
  magma --annotate --snp-loc ./results/${phenoname}.bim --gene-loc /Users/yongbin/Documents/codes/magma/NCBI37.3.gene.loc --out ./results/${phenoname}

  # gene-based analysis
  echo ">> MAGMA gene-based analysis starts ..."
  magma --bfile ${reffile} --gene-annot ./results/${phenoname}.genes.annot --pval ${datapath}/${sumstatname} N=${N} --out ./results/${phenoname}

  # add gene_symbols
  python3 add_gene_symbols.py ./results/${phenoname}.genes.out ./results/${phenoname}.genes.out.txt 
  
  echo "Gzip ${datapath}/${sumstatname}"
  gzip ${datapath}/${sumstatname}
fi

