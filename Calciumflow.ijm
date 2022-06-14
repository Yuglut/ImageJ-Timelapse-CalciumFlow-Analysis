/*
Calcium flow analysis script for ImageJ.
- Given a timelapse image, measures the mean intensity in specified
  regions (selected ROIs) for each frame. One of the selected ROIs
  must be the background in order to subract its mean. Backgnd_idx
  specifies the index of the background ROI.
- Results will be saved in <image_name>-results.txt. Each row 
  corresponds to a given frame and each column to the flux in each ROI
  normalised to the first frame
*/

Backgnd_idx = 15; // 9 but accounts for the 0 start of arrays

sizeRoi = roiManager("count");
if (Backgnd_idx > sizeRoi) {
	exit("Background index greater than ROI depth");
}

getDimensions(width, height, channels, slices, frames); // Get image dimension, we want the number of frames

results = newArray(frames*sizeRoi);
inputDir = getDirectory("image");
imageName = File.nameWithoutExtension ;
//imageName = getTitle();
res_file = inputDir+imageName+"-results.txt";
rem_ROI_att();

for (i = 1; i <= frames; i++) {
	Stack.setFrame(i);
	print("Frame"+i);
	values = get_values(Backgnd_idx,sizeRoi);
	back = values[Backgnd_idx];
	for (k = 0; k < sizeRoi; k++) {
		values[k] -= back;
		results[(i-1)*sizeRoi+k] = values[k];
	}
	if(i==1){
		frame1 = values;	
	}
	Array.print(values);
}


// Initialise the results file
res_String = "Frame";
for (k = 0; k < sizeRoi; k++) {
	roiManager("select", k);
	roi = Roi.getName;
	res_String = res_String+" "+roi;
	}
File.append(res_String,res_file);

for (i = 1; i <= frames; i++) {
	res_String = "";
	res_String = res_String + i;
	for (k = 0; k < sizeRoi; k++) {
		roiManager("select", k);
		roi = Roi.getName;
		if (k != Backgnd_idx) {
//			print(frame1[k]);
			if(frame1[k]==0){
				print("Zero division!");
			}
			results[(i-1)*sizeRoi+k] /= frame1[k];
		}
		res_String = res_String+" "+results[(i-1)*sizeRoi+k];
	}
	File.append(res_String,res_file);
}

print("Results saved in: "+res_file);

function get_values(Backgnd_idx,sizeRoi) { 
// function description
	values = newArray(sizeRoi);
	j=1;
	for (i=0; i<sizeRoi;i++){
		roiManager("select", i);
		if (i==Backgnd_idx) {
			Roi.setName("Background");
		}
		else {
			Roi.setName("Cell"+j);
			j ++;
		}
		roi = Roi.getName;
		values[i] = get_mean();
	}
	return values;
}

function get_mean(){
	run("Measure");
	IJ.renameResults("Results");
	val = getResult("Mean",0);
	if(isNaN(val)){
		exit("NaN encountered, is mean part of the measurements?");
	}
	close("Results");
	return val;
}

function rem_ROI_att() { 
// Remove ROI attributes, to avoid ROI specific to frame
	indexes=Array.getSequence(sizeRoi);
	roiManager("select", indexes);
	roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info");
}
