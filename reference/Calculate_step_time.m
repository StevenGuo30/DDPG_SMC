function step_time = Calculate_step_time(out)
    X = out.X_and_V(:,1);
    Xr = out.Xr;
    time = out.tout;

    Xr_max = max(Xr);
    tolerance = 0.01*Xr_max; % 定义一个小的公差
    index = find(abs(X - 0.9*Xr_max) < tolerance, 1); % 找到第一个几乎等于90%最大值的索引
    step_time = time(index);        
end

