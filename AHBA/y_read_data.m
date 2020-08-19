function [Probes, SampleAnnot, PACall, Expression, Ontology] = y_read_data(datapath)
% Y_READ_DATA is used to read AHBA original data into MATLAB
% by Yongbin Wei, 2018, VU Amsterdam, the Netherlands.

pth = fileparts(mfilename('fullpath'));

cd(datapath);

Probes = readtable('Probes.csv');
SampleAnnot = readtable('SampleAnnot.csv');
PACall = csvread('PACall.csv');
Expression = csvread('MicroarrayExpression.csv');
Ontology = readtable('Ontology.csv');

cd(pth);

end
