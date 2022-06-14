Calcium flow analysis script for ImageJ.
- Given a timelapse image, measures the mean intensity in specified
  regions (selected ROIs) for each frame. One of the selected ROIs
  must be the background in order to subract its mean. Backgnd_idx
  specifies the index of the background ROI.
- Results will be saved in <image_name>-results.txt. Each row 
  corresponds to a given frame and each column to the flux in each ROI
  normalised to the first frame
