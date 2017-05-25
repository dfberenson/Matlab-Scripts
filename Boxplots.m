%NEED TO FIX NUMBERING BE:PW

data1 = input('Variable1: ');
name1 = input('Variable1 name to display: ','s');
data2 = input('Variable2: ');
name1 = input('Variable1 name to display: ','s');
data3 = input('Variable3: ');
name1 = input('Variable1 name to display: ','s');
data4 = input('Variable4: ');
name1 = input('Variable1 name to display: ','s');
data5 = input('Variable5: ');
name1 = input('Variable1 name to display: ','s');
data6 = input('Variable6: ');
name1 = input('Variable1 name to display: ','s');
data7 = input('Variable7: ');
name1 = input('Variable1 name to display: ','s');
data8 = input('Variable8: ');

concat_data = [data1;data2;data3;data4;data5;data6;data7;data8];

label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;
label1 = cell(length(data1),1);
label1{:} = name1;

concat_labels = [label1;label2;label3;label4;label5;label6;label7;label8];

boxplot(concat_data,concat_labels)
