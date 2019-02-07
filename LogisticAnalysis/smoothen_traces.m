
function smoothened_trace = smoothen_traces(raw_trace)

if rand(1) < 0.000
figure
hold on
plot(raw_trace)
plot(movmedian(raw_trace,5))
domain = (1:length(raw_trace))';
ft = polyfit(domain,raw_trace,1);
plot(polyval(ft,domain))
end

% smoothened_trace = raw_trace;
smoothened_trace = movmedian(raw_trace,5);
end