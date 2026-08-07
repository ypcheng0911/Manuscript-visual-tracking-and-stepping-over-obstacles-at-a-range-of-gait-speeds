%%% Conclusion: python resample function (scipy.resample) creates backward
%%% ripple-like behaviors, not ideal for upsampling the timestamps. Use
%%% matlab resample function instead. 

%%% Matlab resample function ended up with the same problem. Interpolation
%%% fucntion turns out to be a good solution (not working in the end of the sequence.) 


% Read output from Gather_detection_results.ipynb 
% and generate verification figures of gaze timing

cd('<path_to_processed_data>\Eye_tracking_videos\All_vars')

% f = dir('N01*.mat');
f = dir('D05*upsample*.mat');
for i=1:length(f)
    load(fullfile(f(1).folder,f(i).name))
    % t_gaze_on_2 = timestamps(find(gaze_in_box_2==1));
    t_gaze_on_2 = timestamps_up(find(gaze_in_box_2==1));
    figure; plot(t_gaze_on_2,'o-')
    title('Timing of gaze on the obstacle')
    ylabel('Time (s)')
    xlabel('Count of gaze')
    saveas(gcf,[Condition,'_upsample_screening.png'])
end


%
figure
for frame_num = 1000:2000
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0(frame_num,1)-box_0(frame_num,3)/2 box_0(frame_num,1)+box_0(frame_num,3)/2 box_0(frame_num,1)+box_0(frame_num,3)/2 box_0(frame_num,1)-box_0(frame_num,3)/2 ;...
        box_0(frame_num,2)-box_0(frame_num,4)/2 box_0(frame_num,2)-box_0(frame_num,4)/2 box_0(frame_num,2)+box_0(frame_num,4)/2 box_0(frame_num,2)+box_0(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1(frame_num,1)-box_1(frame_num,3)/2 box_1(frame_num,1)+box_1(frame_num,3)/2 box_1(frame_num,1)+box_1(frame_num,3)/2 box_1(frame_num,1)-box_1(frame_num,3)/2 ;...
        box_1(frame_num,2)-box_1(frame_num,4)/2 box_1(frame_num,2)-box_1(frame_num,4)/2 box_1(frame_num,2)+box_1(frame_num,4)/2 box_1(frame_num,2)+box_1(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2(frame_num,1)-box_2(frame_num,3)/2 box_2(frame_num,1)+box_2(frame_num,3)/2 box_2(frame_num,1)+box_2(frame_num,3)/2 box_2(frame_num,1)-box_2(frame_num,3)/2 ;...
        box_2(frame_num,2)-box_2(frame_num,4)/2 box_2(frame_num,2)-box_2(frame_num,4)/2 box_2(frame_num,2)+box_2(frame_num,4)/2 box_2(frame_num,2)+box_2(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi(frame_num,1)-box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)+box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)+box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)-box_2_multi(frame_num,3)/2 ;...
        box_2_multi(frame_num,2)-box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)-box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)+box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)+box_2_multi(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(gaze_x_px(frame_num),-gaze_y_px(frame_num),'ro')
    hold off;
    pause(0.025)
end

% upsampled data
figure
for frame_num = 4000:8000
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0_up(frame_num,1)-box_0_up(frame_num,3)/2 box_0_up(frame_num,1)+box_0_up(frame_num,3)/2 box_0_up(frame_num,1)+box_0_up(frame_num,3)/2 box_0_up(frame_num,1)-box_0_up(frame_num,3)/2 ;...
        box_0_up(frame_num,2)-box_0_up(frame_num,4)/2 box_0_up(frame_num,2)-box_0_up(frame_num,4)/2 box_0_up(frame_num,2)+box_0_up(frame_num,4)/2 box_0_up(frame_num,2)+box_0_up(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1_up(frame_num,1)-box_1_up(frame_num,3)/2 box_1_up(frame_num,1)+box_1_up(frame_num,3)/2 box_1_up(frame_num,1)+box_1_up(frame_num,3)/2 box_1_up(frame_num,1)-box_1_up(frame_num,3)/2 ;...
        box_1_up(frame_num,2)-box_1_up(frame_num,4)/2 box_1_up(frame_num,2)-box_1_up(frame_num,4)/2 box_1_up(frame_num,2)+box_1_up(frame_num,4)/2 box_1_up(frame_num,2)+box_1_up(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2_up(frame_num,1)-box_2_up(frame_num,3)/2 box_2_up(frame_num,1)+box_2_up(frame_num,3)/2 box_2_up(frame_num,1)+box_2_up(frame_num,3)/2 box_2_up(frame_num,1)-box_2_up(frame_num,3)/2 ;...
        box_2_up(frame_num,2)-box_2_up(frame_num,4)/2 box_2_up(frame_num,2)-box_2_up(frame_num,4)/2 box_2_up(frame_num,2)+box_2_up(frame_num,4)/2 box_2_up(frame_num,2)+box_2_up(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi_up(frame_num,1)-box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)+box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)+box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)-box_2_multi_up(frame_num,3)/2 ;...
        box_2_multi_up(frame_num,2)-box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)-box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)+box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)+box_2_multi_up(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(gaze_x_px(frame_num),-gaze_y_px(frame_num),'ro')
    hold off;
    pause(0.005)
end

%
v = VideoWriter("D10_15ms_10x_original.avi");
open(v)
figure
for frame_num = 1:length(box_0)
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0(frame_num,1)-box_0(frame_num,3)/2 box_0(frame_num,1)+box_0(frame_num,3)/2 box_0(frame_num,1)+box_0(frame_num,3)/2 box_0(frame_num,1)-box_0(frame_num,3)/2 ;...
        box_0(frame_num,2)-box_0(frame_num,4)/2 box_0(frame_num,2)-box_0(frame_num,4)/2 box_0(frame_num,2)+box_0(frame_num,4)/2 box_0(frame_num,2)+box_0(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1(frame_num,1)-box_1(frame_num,3)/2 box_1(frame_num,1)+box_1(frame_num,3)/2 box_1(frame_num,1)+box_1(frame_num,3)/2 box_1(frame_num,1)-box_1(frame_num,3)/2 ;...
        box_1(frame_num,2)-box_1(frame_num,4)/2 box_1(frame_num,2)-box_1(frame_num,4)/2 box_1(frame_num,2)+box_1(frame_num,4)/2 box_1(frame_num,2)+box_1(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2(frame_num,1)-box_2(frame_num,3)/2 box_2(frame_num,1)+box_2(frame_num,3)/2 box_2(frame_num,1)+box_2(frame_num,3)/2 box_2(frame_num,1)-box_2(frame_num,3)/2 ;...
        box_2(frame_num,2)-box_2(frame_num,4)/2 box_2(frame_num,2)-box_2(frame_num,4)/2 box_2(frame_num,2)+box_2(frame_num,4)/2 box_2(frame_num,2)+box_2(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi(frame_num,1)-box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)+box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)+box_2_multi(frame_num,3)/2 box_2_multi(frame_num,1)-box_2_multi(frame_num,3)/2 ;...
        box_2_multi(frame_num,2)-box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)-box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)+box_2_multi(frame_num,4)/2 box_2_multi(frame_num,2)+box_2_multi(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(gaze_x_px(frame_num),-gaze_y_px(frame_num),'ro')
    hold off;
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)

% upsampled data
v = VideoWriter("D10_15ms_10x_upsampled.avi");
open(v)
figure
for frame_num = 1:length(box_0_up)
    plot(960,-540)
    set(gca,'xlim',[0 1920],'ylim',[-1080 0],'xtick',[0 960 1920],'ytick',[-1080 -540 0],'YTickLabel',[1080 540 0])

    %frame_num = 81;
    v0 = [box_0_up(frame_num,1)-box_0_up(frame_num,3)/2 box_0_up(frame_num,1)+box_0_up(frame_num,3)/2 box_0_up(frame_num,1)+box_0_up(frame_num,3)/2 box_0_up(frame_num,1)-box_0_up(frame_num,3)/2 ;...
        box_0_up(frame_num,2)-box_0_up(frame_num,4)/2 box_0_up(frame_num,2)-box_0_up(frame_num,4)/2 box_0_up(frame_num,2)+box_0_up(frame_num,4)/2 box_0_up(frame_num,2)+box_0_up(frame_num,4)/2];
    v0 = v0' .* [1 -1];
    v1 = [box_1_up(frame_num,1)-box_1_up(frame_num,3)/2 box_1_up(frame_num,1)+box_1_up(frame_num,3)/2 box_1_up(frame_num,1)+box_1_up(frame_num,3)/2 box_1_up(frame_num,1)-box_1_up(frame_num,3)/2 ;...
        box_1_up(frame_num,2)-box_1_up(frame_num,4)/2 box_1_up(frame_num,2)-box_1_up(frame_num,4)/2 box_1_up(frame_num,2)+box_1_up(frame_num,4)/2 box_1_up(frame_num,2)+box_1_up(frame_num,4)/2];
    v1 = v1' .* [1 -1];
    v2 = [box_2_up(frame_num,1)-box_2_up(frame_num,3)/2 box_2_up(frame_num,1)+box_2_up(frame_num,3)/2 box_2_up(frame_num,1)+box_2_up(frame_num,3)/2 box_2_up(frame_num,1)-box_2_up(frame_num,3)/2 ;...
        box_2_up(frame_num,2)-box_2_up(frame_num,4)/2 box_2_up(frame_num,2)-box_2_up(frame_num,4)/2 box_2_up(frame_num,2)+box_2_up(frame_num,4)/2 box_2_up(frame_num,2)+box_2_up(frame_num,4)/2];
    v2 = v2' .* [1 -1];
    v2m = [box_2_multi_up(frame_num,1)-box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)+box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)+box_2_multi_up(frame_num,3)/2 box_2_multi_up(frame_num,1)-box_2_multi_up(frame_num,3)/2 ;...
        box_2_multi_up(frame_num,2)-box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)-box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)+box_2_multi_up(frame_num,4)/2 box_2_multi_up(frame_num,2)+box_2_multi_up(frame_num,4)/2];
    v2m = v2m' .* [1 -1];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v0,'FaceColor','None','EdgeColor','Green')
    patch('Faces',f,'Vertices',v1,'FaceColor','None','EdgeColor','Yellow')
    patch('Faces',f,'Vertices',v2,'FaceColor','None','EdgeColor','Blue')
    patch('Faces',f,'Vertices',v2m,'FaceColor','None','EdgeColor','Blue')
    hold on;
    scatter(gaze_x_px(frame_num),-gaze_y_px(frame_num),'ro')
    hold off;
    frame = getframe(gcf);
    writeVideo(v,frame)
end
close(v)
