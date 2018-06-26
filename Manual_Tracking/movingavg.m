function x = movavg(A,varargin)

    if nargin > 1
        k = varargin{1};
    else
        k = 5;
    end
    
    if rem(k,2) == 0 || rem(k,1) ~= 0 || k < 0
        error('Window size must be an odd integer');
    end

    windowrad = (k-1)/2;

    if isrow(A)
        for i = 1:length(A)
            leftindex = max(1 , i - windowrad);
            rightindex = min(length(A) , i + windowrad);
            x(1,i) = mean(A(leftindex:rightindex));
        end
    end
    
    if iscolumn(A)
        for i = 1:length(A)
            leftindex = max(1 , i - windowrad);
            rightindex = min(length(A) , i + windowrad);
            x(i,1) = mean(A(leftindex:rightindex));
        end
    end
    
end