%Arguments are (trace as a column vector , ~frames to skip at start , ~frames to skip at end, ~'plot')
function t = findG1S(trace,varargin)

    [h,w] = size(trace);
    assert(h == 1 || w == 1)
    if h == 1
        trace = trace';
    end

    %Eliminate NaN
    clean_trace = trace(trace > -1000000);
    if nargin == 2
        beginningframestoskip = varargin{1};
        clean_trace = clean_trace(beginningframestoskip + 1 : end);
    elseif nargin > 2
        beginningframestoskip = varargin{1};
        endingframestoskip = varargin{2};
        clean_trace = clean_trace(beginningframestoskip + 1 : end - endingframestoskip);
    end
    
    times = [1:length(clean_trace)]';
    ftype = fittype('max(a,b*x+c)');
    maxfit = fit(times,clean_trace,ftype,'StartPoint',[1 1 1]);
    t = (maxfit.a - maxfit.c)/maxfit.b;
    
    if nargin > 3
        if strcmp(varargin{3},'plot')
            figure()
            hold on  
            plot(times,clean_trace)
            plot(maxfit)
        end
    end
    
    if t<1
        t=1;
    elseif t>length(trace)
        t=length(trace);
    end
end