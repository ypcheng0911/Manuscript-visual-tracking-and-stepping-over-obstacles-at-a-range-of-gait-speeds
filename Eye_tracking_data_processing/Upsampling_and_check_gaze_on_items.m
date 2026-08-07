clear all
clc
close all

cd('E:\Nordin_lab_data\Processed_data\Obstacle_avoidance\Eye_tracking_videos\All_vars')

subj_list = {'N02', 'N05'};
% subj_list = {'N06','N07','N08','N09','N10'...
%     ,'D01','D02','D03','D04','D06','D07','D08','D09','D10'};
for s = 1:length(subj_list)
    subj = subj_list{s};
    files = dir([subj,'*x_summary.mat']);
    for i=1:length(files)
        clearvars -except subj_list s subj files i
        load(fullfile(files(1).folder,files(i).name))
        box_0_up = interp_with_nan(box_0);
        box_1_up = interp_with_nan(box_1);
        box_2_up = interp_with_nan(box_2);
        box_2_multi_up = interp_with_nan(box_2_multi);
        timestamps_up = interp_with_nan(timestamps);

        eyedata_t = nan(1,length(raw_gaze_timestamp));

        gaze_in_box_0_up = nan(1,length(raw_gaze_timestamp));
        gaze_in_box_1_up = nan(1,length(raw_gaze_timestamp));
        gaze_in_box_2_up = nan(1,length(raw_gaze_timestamp));
        gaze_in_box_2_multi_up = nan(1,length(raw_gaze_timestamp));
        box_0_sequence = nan(length(raw_gaze_timestamp),4);
        box_1_sequence = nan(length(raw_gaze_timestamp),4);
        box_2_sequence = nan(length(raw_gaze_timestamp),4);
        box_2_multi_sequence = nan(length(raw_gaze_timestamp),4);
        for t = 1:length(raw_gaze_timestamp)
            [val(t),frame_idx(t)] = min(abs(raw_gaze_timestamp(t)-timestamps_up));
            if val(t) < 0.0055
                eyedata_t(t) = raw_gaze_timestamp(t);
                gaze_in_box_0_up(t) = in_this_box(raw_gaze_x_px(t),raw_gaze_y_px(t),box_0_up(frame_idx(t),:));
                gaze_in_box_1_up(t) = in_this_box(raw_gaze_x_px(t),raw_gaze_y_px(t),box_1_up(frame_idx(t),:));
                gaze_in_box_2_up(t) = in_this_box(raw_gaze_x_px(t),raw_gaze_y_px(t),box_2_up(frame_idx(t),:));
                gaze_in_box_2_multi_up(t) = in_this_box(raw_gaze_x_px(t),raw_gaze_y_px(t),box_2_multi_up(frame_idx(t),:));

                box_0_sequence(t,:) = box_0_up(frame_idx(t),:);
                box_1_sequence(t,:) = box_1_up(frame_idx(t),:);
                box_2_sequence(t,:) = box_2_up(frame_idx(t),:);
                box_2_multi_sequence(t,:) = box_2_multi_up(frame_idx(t),:);
            end
        end

        save_file_name = files(i).name;
        save_file_name = [save_file_name(1:end-4),'_matlab_processed.mat'];
        save(fullfile(files(1).folder,save_file_name))
    end

end
%{
t_gaze_on_2 = eyedata_t(find(gaze_in_box_2_up==1));
figure; plot(t_gaze_on_2,'o-')
title('Timing of gaze on the obstacle')
ylabel('Time (s)')
xlabel('Count of gaze')

t_gaze_on_2 = timestamps_up(find(gaze_in_box_2_up==1));
figure; plot(t_gaze_on_2,'o-')
title('Timing of gaze on the obstacle')
ylabel('Time (s)')
xlabel('Count of gaze')
%}

%{
% upsampled data
figure
for frame_num = 2001:4000
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0_sequence(frame_num,1)-box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)+box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)+box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)-box_0_sequence(frame_num,3)/2 ;...
        box_0_sequence(frame_num,2)-box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)-box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)+box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)+box_0_sequence(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1_sequence(frame_num,1)-box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)+box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)+box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)-box_1_sequence(frame_num,3)/2 ;...
        box_1_sequence(frame_num,2)-box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)-box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)+box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)+box_1_sequence(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2_sequence(frame_num,1)-box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)+box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)+box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)-box_2_sequence(frame_num,3)/2 ;...
        box_2_sequence(frame_num,2)-box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)-box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)+box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)+box_2_sequence(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi_sequence(frame_num,1)-box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)+box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)+box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)-box_2_multi_sequence(frame_num,3)/2 ;...
        box_2_multi_sequence(frame_num,2)-box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)-box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)+box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)+box_2_multi_sequence(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(raw_gaze_x_px(frame_num),-raw_gaze_y_px(frame_num),'ro')
    hold off;
    pause(0.005)
end

% upsampled data
v = VideoWriter("upsampled.avi");
open(v)
figure
for frame_num = 1:length(box_0_sequence)
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0_sequence(frame_num,1)-box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)+box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)+box_0_sequence(frame_num,3)/2 box_0_sequence(frame_num,1)-box_0_sequence(frame_num,3)/2 ;...
        box_0_sequence(frame_num,2)-box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)-box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)+box_0_sequence(frame_num,4)/2 box_0_sequence(frame_num,2)+box_0_sequence(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1_sequence(frame_num,1)-box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)+box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)+box_1_sequence(frame_num,3)/2 box_1_sequence(frame_num,1)-box_1_sequence(frame_num,3)/2 ;...
        box_1_sequence(frame_num,2)-box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)-box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)+box_1_sequence(frame_num,4)/2 box_1_sequence(frame_num,2)+box_1_sequence(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2_sequence(frame_num,1)-box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)+box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)+box_2_sequence(frame_num,3)/2 box_2_sequence(frame_num,1)-box_2_sequence(frame_num,3)/2 ;...
        box_2_sequence(frame_num,2)-box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)-box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)+box_2_sequence(frame_num,4)/2 box_2_sequence(frame_num,2)+box_2_sequence(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi_sequence(frame_num,1)-box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)+box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)+box_2_multi_sequence(frame_num,3)/2 box_2_multi_sequence(frame_num,1)-box_2_multi_sequence(frame_num,3)/2 ;...
        box_2_multi_sequence(frame_num,2)-box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)-box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)+box_2_multi_sequence(frame_num,4)/2 box_2_multi_sequence(frame_num,2)+box_2_multi_sequence(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(raw_gaze_x_px(frame_num),-raw_gaze_y_px(frame_num),'ro')
    hold off;
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)

%}

function output = in_this_box(x,y,box)
x_in = abs(x-box(1)) < box(3)/2; 
y_in = abs(y-box(2)) < box(4)/2;
output = x_in & y_in;
end

function output = interp_with_nan(input)
flag = 0;
if isvector(input)
    if length(input)>1000
        output = zeros(1,length(input)*4-3);
        for i=1:ceil(length(input)/1000)
            if i==ceil(length(input)/1000)
                temp_input = input(1+(i-1)*1000:end);
                if length(temp_input) < 10
                    flag = 1;
                    temp_input = input(1+(i-2)*1000:end);
                end
            else
                temp_input = input(1+(i-1)*1000:1001+(i-1)*1000);
            end
            mean_temp = mean(temp_input,'omitnan');
            temp_input = temp_input-mean_temp;
            nan_locs = find(isnan(temp_input));
            temp_input(nan_locs) = 0;
            temp_output = interp(temp_input,4);
            % temp_output(1+(nan_locs-1)*4) = nan;
            for n = 1:length(nan_locs)
                nn = nan_locs(n);
                try
                    temp_output(1+(nn-1)*4-3 : 1+(nn-1)*4+3) = nan;
                catch
                    temp_output(1+(nn-1)*4 : 1+(nn-1)*4+3) = nan;
                end
            end
            temp_output = temp_output(1:end-3) + mean_temp;
            if i==ceil(length(input)/1000)
                if flag==1
                    output(1+(i-2)*4000:end) = temp_output;
                else
                    output(1+(i-1)*4000:end) = temp_output;
                end
            elseif i==1
                output(1:4001) = temp_output;
            else
                output(1+(i-1)*4000:4001+(i-1)*4000) = temp_output;
            end
        end
    else
        nan_locs = find(isnan(input));
        input(nan_locs) = 0;
        output = interp(input,4);
        output(1+(nan_locs-1)*4) = nan;
        output = output(1:end-3);
    end
else
    if length(input)>1000
        output = zeros(length(input)*4-3,4);
        for i=1:ceil(length(input)/1000)
            for j=1:size(input,2)
                if i==ceil(length(input)/1000)
                    temp_input = input(1+(i-1)*1000:end,j);
                    if length(temp_input) < 10
                        flag = 1;
                        temp_input = input(1+(i-2)*1000:end,j);
                    end
                else
                    temp_input = input(1+(i-1)*1000:1001+(i-1)*1000,j);
                end
                mean_temp = mean(temp_input,'omitnan');
                temp_input = temp_input-mean_temp;
                nan_locs = find(isnan(temp_input));
                temp_input(nan_locs) = 0;
                temp_output = interp(temp_input,4);
                for n = 1:length(nan_locs)
                    nn = nan_locs(n);
                    try
                        temp_output(1+(nn-1)*4-3 : 1+(nn-1)*4+3) = nan;
                    catch
                        temp_output(1+(nn-1)*4 : 1+(nn-1)*4+3) = nan;
                    end
                end
                temp_output = temp_output(1:end-3) + mean_temp;
                if i==ceil(length(input)/1000)
                    if flag==1
                        output(1+(i-2)*4000:end,j) = temp_output;
                    else
                        output(1+(i-1)*4000:end,j) = temp_output;
                    end
                elseif i==1
                    output(1:4001,j) = temp_output;
                else
                    output(1+(i-1)*4000:4001+(i-1)*4000,j) = temp_output;
                end
            end
        end
    else
        for i=1:size(input,2)
            temp_input = input(:,i);
            nan_locs = find(isnan(temp_input));
            temp_input(nan_locs) = 0;
            output(:,i) = interp(temp_input,4);
            output(1+(nan_locs-1)*4,i) = nan;
        end
        output = output(1:end-3,:);
    end
end
end