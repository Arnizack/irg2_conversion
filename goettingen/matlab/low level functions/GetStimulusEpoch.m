function [StimOn,StimOff] = GetStimulusEpoch(input)

max_input = max(input(4000:end));
min_input = quantile(input(4000:end),0.01);

threshold = max_input*0.5+min_input*0.5;
close all 
plot(input);
yline(threshold);
beginning = mean(input(1:100));
% Wenn der puls nach unten geht, drehe das signal um
if(beginning>threshold)
    input = input*-1;
end


%max_input = max(input);
max_input = max(input(4000:end)); % changed it because sometimes flipping caused an issue for very small pulses


lower_quantile = quantile(input,0.05);



threshold = max_input*0.5+lower_quantile*0.5;



above_threshold_mask = input>threshold;
diff_of_mask = diff(above_threshold_mask);

%left_crossing sind die Zeiten in denen das Signal über den Threshold steigt
left_crossings = find(diff_of_mask==1);

%right_crossing sind die Zeiten in denen das Singal unter den Threshold
%fällt

right_crossings = find(diff_of_mask==-1);


max_stim_length = 0;
max_right_idx =-1;
max_left_idx  =-1;

%For debugging
tiledlayout(3,1)
nexttile
plot(input)
yline(threshold);
title("input")




nexttile
plot(above_threshold_mask)
title("above threshold mask")

nexttile
plot(diff_of_mask)
title("diff of mask")

%Wenn das Signal zu oft den Threshold über und untersteigt, hat das Signal
%zu viel Rauschen
if(length(left_crossings)>50 || length(right_crossings)>50)
    disp("Signal is to noisy");
    StimOn = 1;
    StimOff = 2;
    return;
end

% Die Zeit beidenen das Signal über den Threshold steigt und darauf wieder
% unter den Threshold fällt bilden Paare.
% Ziel ist es das Paar zu finden desses Zeitabstand der längste ist.
right_i = 1;
for left_i=1:length(left_crossings)
    
    while right_i <= length(right_crossings) && left_crossings(left_i)>right_crossings(right_i)
        right_i= right_i + 1;
        
    end

    if(right_i > length(right_crossings))
        break;
    end

    tmp_stim_length = right_crossings(right_i)-left_crossings(left_i);
    if(tmp_stim_length>max_stim_length)
        max_right_idx = right_i;
        max_left_idx = left_i;
    end
    
    right_i = right_i + 1;

end

StimOn = left_crossings(max_left_idx);
StimOff = right_crossings(max_right_idx);

plot(diff_of_mask);

plot(input)

plot(above_threshold_mask);

%% Steigungsrate ramp: 25 p amp/s

%% Rampe: Maximale Länge 20 Sekunden
%% 

end