from ultralytics import YOLO
import glob
# Initialize YOLO with the Model Name
model = YOLO("my_model.pt")

# Retrive all video paths
path = "E:\\Nordin_lab_data\\Raw_data\\Obstacle Avoidance Study raw data\\Eye tracking raw data\\N01\\Data\\Media"
path_len = len(path)
file_names = []
video_paths = []
for files in glob.glob(path + '\\*.mp4'):
    video_paths.append(files)
    file_names.append(files[path_len+1:])

save_path = "E:\\Nordin_lab_data\\Processed_data\\Obstacle_avoidance\\Eye_tracking_videos\\N01"
# Iterate through all videos
n = 0
for cur_video in video_paths:
    # Predict Method Takes all the parameters of the Command Line Interface
    model.predict(source=cur_video, conf=0.5, save=True, save_txt=True, save_conf=True, project=save_path, name=file_names[n])
    n += 1
