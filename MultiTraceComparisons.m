
%Import data as a Numeric Matrix


mytable_expt1 = expt170308;
mytable_expt2 = expt170421;
framerate1 = 5;
framerate2 = 30;

numtraces_expt1 = length(mytable_expt1(1,:));
traces_expt1 = cell(1,numtraces_expt1);
for i = 1:numtraces_expt1
    thistrace = mytable_expt1(:,i);
    traces_expt1{i} = thistrace(thistrace > -1000000);
end


numtraces_expt2 = length(mytable_expt2(1,:));
traces_expt2 = cell(1,numtraces_expt2);
for i = 1:numtraces_expt2
    thistrace = mytable_expt2(:,i);
    traces_expt2{i} = thistrace(thistrace > -1000000);
end

 
figure()
xlabel('Time (min)')
ylabel('Size reporter')
axis([0 inf 0 inf])
hold on
for i = 1:numtraces_expt1
    thistrace = traces_expt1{i};
    times = 0:framerate1:framerate1*(length(thistrace)-1);
    times = times.';
    plot(times,thistrace,'r')
end
for i = 1:numtraces_expt2
    thistrace = traces_expt2{i};
    times = 0:framerate2:framerate2*(length(thistrace)-1);
    times = times.';
    plot(times,thistrace,'g')
end
hold off

figure()
xlabel('Time (min)')
ylabel('Size reporter')
axis([0 inf 0 inf])
hold on
for i = 1:numtraces_expt1
    thistrace = traces_expt1{i};
    times = 0:framerate1:framerate1*(length(thistrace)-1);
    times = times.';
    plot(times,movavg(thistrace,5),'r')
    
    %Take average of timepoints 10:14 for birth and penultimate 4 for mitosis
    birthsizes_expt1(i) = mean(thistrace(10:14));
    mitosissizes_expt1(i) = mean(thistrace(end-8:end-4));
    cyclelengths_expt1(i) = length(thistrace)*framerate1;
end
for i = 1:numtraces_expt2
    thistrace = traces_expt2{i};
    times = 0:framerate2:framerate2*(length(thistrace)-1);
    times = times.';
    plot(times,movavg(thistrace,5),'g')
    birthsizes_expt2(i) = mean(thistrace(3:7));
    mitosissizes_expt2(i) = mean(thistrace(end-4:end));
    cyclelengths_expt2(i) = length(thistrace)*framerate2;
end

allbirthsizes = [birthsizes_expt1 birthsizes_expt2];
allmitosissizes = [mitosissizes_expt1 mitosissizes_expt2];
allcyclelengths = [cyclelengths_expt1 cyclelengths_expt2];

groupnames = cell(1,numtraces_expt1 + numtraces_expt2);
groupnames(1:numtraces_expt1) = {'5 min framerate'};
groupnames(end - numtraces_expt2 + 1 : end) = {'30 min framerate'};

figure('Name','Sizes at birth')
axis([0 inf 0 inf])
boxplot(allbirthsizes,groupnames)

figure('Name','Sizes at mitosis')
axis([0 inf 0 inf])
boxplot(allmitosissizes,groupnames)

figure('Name','Sizes at mitosis / Sizes at birth')
axis([0 inf 0 inf])
boxplot(allmitosissizes./allbirthsizes,groupnames)

figure('Name','Cell cycle lengths')
axis([0 inf 0 inf])
boxplot(allcyclelengths,groupnames)


allbirthandmitosissizes = [allbirthsizes allmitosissizes];
combinedgroupnames = cell(1,length(allbirthandmitosissizes));
combinedgroupnames(1:numtraces_expt1) = {'Sizes at birth (frames q5min)'};
combinedgroupnames(numtraces_expt1 + 1 : length(allbirthsizes)) = {'Sizes at birth (frames q30min)'};
combinedgroupnames(length(allbirthsizes) + 1 : length(allbirthsizes) + numtraces_expt1) = {'Sizes at mitosis (frames q5min)'};
combinedgroupnames(length(allbirthsizes) + numtraces_expt1 + 1 : end) = {'Sizes at mitosis (frames q30min)'};

figure('Name','Sizes')
axis([0 inf 0 inf])
boxplot(allbirthandmitosissizes,combinedgroupnames)
ylabel('Size reporter')