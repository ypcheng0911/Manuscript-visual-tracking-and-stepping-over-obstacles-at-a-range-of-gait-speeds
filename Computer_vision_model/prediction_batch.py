from ultralytics import YOLO
import glob
# Initialize YOLO with the Model Name
model = YOLO("my_model.pt")
subjects = ["D03","D04","D05","D06","D07","D08","D09","D10_obstacle_avoidance","N02","N03","N04","N05","N06","N07","N08","N09","N10"]

for subj in subjects:
    # Retrive all video paths
    path = "<path_to_raw_data>\\"+ subj +"\\Data\\Media"
    path_len = len(path)
    file_names = []
    video_paths = []
    for files in glob.glob(path + '\\*.mp4'):
        video_paths.append(files)
        file_names.append(files[path_len+1:])

    save_path = "<path_to_processed_data>\\" + subj
    # Iterate through all videos
    n = 0
    for cur_video in video_paths:
        # Predict Method Takes all the parameters of the Command Line Interface
        model.predict(source=cur_video, conf=0.5, save=False, save_txt=True, save_conf=True, project=save_path, name=file_names[n])
        n += 1
