from ultralytics import YOLO
import glob
# Initialize YOLO with the Model Name
model = YOLO("my_model.pt")

# Retrive all video paths
path = "<path_to_raw_data>\\N01\\Data\\Media"
path_len = len(path)
file_names = []
video_paths = []
for files in glob.glob(path + '\\*.mp4'):
    video_paths.append(files)
    file_names.append(files[path_len+1:])

save_path = "<path_to_processed_data>\\N01"
# Iterate through all videos
n = 0
for cur_video in video_paths:
    # Predict Method Takes all the parameters of the Command Line Interface
    model.predict(source=cur_video, conf=0.5, save=True, save_txt=True, save_conf=True, project=save_path, name=file_names[n])
    n += 1
