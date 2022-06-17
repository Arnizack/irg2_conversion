function StimOn = GetRampStimulusEpoch(input,StimOff,x_scale,y_scale)
    close all  
    hold on
    plot(input)
    
    
    lower_quantile = quantile(input,0.1);

    mask_lower = input>=lower_quantile;

    start_fit = find(diff(mask_lower)==1);
    start_fit = start_fit(length(start_fit));%take last element
    
    
    %x = [start_fit:StimOff];
    %ideal_ramp_line = x*25*x_scale;

    %input_T = transpose(input(start_fit:StimOff));

    %displacement = mean(ideal_ramp_line-input_T);

    %x = [1:length(input)];
    %ideal_ramp_line = x*25*x_scale - displacement;

    x = [start_fit:StimOff];
    X = [ones(StimOff-start_fit+1,1),transpose(x)];

    b=X\input(start_fit:StimOff);



    x = [1:length(input)];
    ideal_ramp_line = b(1)+x*b(2);

    disp(['Ramp gradient: ',num2str(b(2))])

    min_val = quantile(input,0.01);

    StimOn = find(diff(min_val<=ideal_ramp_line)==1);
    plot(ideal_ramp_line);
    
    xline(StimOff);
    xline(StimOn);
    hold off

end