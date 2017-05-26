foldername = 'C:\Users\Skotheim Lab\Desktop\Test images\Measurements\DFB_170520_HMEC_1GFiii_photobleaching measurements';
filename = 'AllIntegratedIntensities';
filepath = [foldername '\' filename '.xlsx'];

datastruct = importdata(filepath);
headers = datastruct.colheaders;
data = datastruct.data;
totalnumdatapoints = nnz(~isnan(data));
concatdata = zeros(totalnumdatapoints,1);
concatexptnames = cell(totalnumdatapoints,1);
count = 1;

for expt = 1:length(headers)
   thesedata = data(:,expt); 
   thesedata = thesedata(~isnan(thesedata));
   thisexptname = headers(expt);
   theseexptnames = cell(length(thesedata),1);
   theseexptnames(:) = {thisexptname{1}};
   concatdata(count : count + length(thesedata) - 1) = thesedata;
   concatexptnames(count : count + length(thesedata) - 1) = theseexptnames;
   count = count + length(thesedata);
end

boxplot(concatdata,concatexptnames)
ylabel(input('y-axis label: ','s'));





% 
% 
% data1 = input('Variable1: ');
% name1 = input('Variable1 name to display: ','s');
% data2 = input('Variable2: ');
% name2 = input('Variable2 name to display: ','s');
% data3 = input('Variable3: ');
% name3 = input('Variable3 name to display: ','s');
% data4 = input('Variable4: ');
% name4 = input('Variable4 name to display: ','s');
% data5 = input('Variable5: ');
% name5 = input('Variable5 name to display: ','s');
% data6 = input('Variable6: ');
% name6 = input('Variable6 name to display: ','s');
% data7 = input('Variable7: ');
% name7 = input('Variable7 name to display: ','s');
% data8 = input('Variable8: ');
% name8 = input('Variable7 name to display: ','s');
% 
% data1 = BeforeConstant1
% 
% 
% 
% concat_data = [data1;data2;data3;data4;data5;data6;data7;data8];
% 
% label1 = cell(length(data1),1);
% label1(:) = {name1};
% label2 = cell(length(data2),1);
% label2(:) = {name2};
% label3 = cell(length(data3),1);
% label3(:) = {name3};
% label4 = cell(length(data4),1);
% label4(:) = {name4};
% label5 = cell(length(data5),1);
% label5(:) = {name5};
% label6 = cell(length(data6),1);
% label6(:) = {name6};
% label7 = cell(length(data7),1);
% label7(:) = {name7};
% label8 = cell(length(data8),1);
% label8(:) = {name8};
% 
% 
% concat_labels = [label1;label2;label3;label4;label5;label6;label7;label8];
% 
% boxplot(concat_data,concat_labels)
