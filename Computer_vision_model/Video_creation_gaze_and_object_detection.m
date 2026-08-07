%%% Apply eye tracking trajectory on object detection video
load('N01N01_10ms_125x_summary.mat')
v = VideoReader("E:\Nordin_lab_data\Processed_data\Obstacle_avoidance\Eye_tracking_videos\N01\qgZdNuR91M7PeDbLGndGLg==.mp4\qgZdNuR91M7PeDbLGndGLg==.avi");
v2 = VideoWriter("testing_2.avi");
open(v2)
for i=1:v.NumFrames
    frame = read(v,i);
    imshow(frame)
    hold on
    scatter(gaze_x_px(i),gaze_y_px(i),'ro','linewidth',2)
    hold off
    frame2 = getframe(gcf);
    writeVideo(v2,frame2)
end
close(v2)

