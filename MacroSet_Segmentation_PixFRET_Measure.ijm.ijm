/* By Helena Canever, Borghi Lab "Mechanotransduction: from cell surface to nucleus" @ Institut Jacques Monod. Contact at helena.canever@ijm.fr
 * 
 * This is a Macro Set that can perform Segmentation, 
 * PixFRET execution, and 
 * Measure the FRET Index of the generated Regions Of Interest on a folder of images or single images. 
 * Works for lsm and czi formats
 * It is specifically designed for the segmentation of Focal Adhesion but feel free to change it to suit your needs.
 * The macro works on spectral images, specifically with donor emission on channel 3 and acceptor emission in channel 7. If you wish measure the FRET using different channel please takes this into account.
 * 
 * TO USE: Open ImageJ > Plugins > Macros > Install... 
 * Then Click on the Macros in Plugins > Macros 
*/ 

/* "Segmentation" performs a basic segmentation (with a bit of help from the user) and creates a folder called "ROI Sets" 
 *  in the same folder that is analysed or in the folder containing the image in case of single image analysis.
 *  Remember to check the scale (micrometers to pixels) and correct the macro if different from the script.
 *  Also, calibrate the Analyze Particles values to what best suits your needs. E.g. if working on FAs, analyse small and elongated particles but avoid very small and very circular particles. 
 *  If working on nuclei, aim for big and round particles!
 */

macro "Segmentation" { 

	boolean = getBoolean("Am I working on a folder of images or a single image?", "Folder", "Single image"); // let's you choose between folder (True==1) or image (False==0) analysis
	
	if (boolean==1) { // beginning of folder analysis
		
		image_directory = getDirectory("Choose a directory");
		list = getFileList(image_directory);
		ROISets = image_directory + File.separator + "ROI Sets";
		
		if (!File.exists(ROISets)) {								//this bit of code checks if a ROI Sets folder exists in the chosen folder, if not it creates one 
			File.makeDirectory(image_directory + File.separator + "ROI Sets");
			}
		
		for (i = 0; i < list.length; i++) {
			
				
				if (!File.isDirectory(list[i])) {  //checks that the file is not a folder (it would jam the code) and if so it executes the rest of the code
					open(list[i]);		// opening of file to be segmented
			        image_title = getTitle();	
					run("Duplicate...", "duplicate channels=7");	// duplication of channel 7 for analysis
					selectImage(1);	//selects the original image
					close(); 	//closes the original image
				
					// beginning of segmentation
					run("Subtract Background...", "rolling=5 sliding");	//runs Subtract Background with Rolling Ball radius=5.0 pixels (arbitrary value)
					run("Gaussian Blur...", "sigma=2");	//runs Gaussian Blur... filter with a sigma=2 (arbitrary value)
					setAutoThreshold("Default dark");	//sets the thresholding alghorythm to Default and the background to Dark
					run("Threshold...");
					waitForUser ("Manual threshold", "Please, adjust the threshold as desired then click 'Apply' and 'OK'"); // human thresholding
					selectWindow("Threshold");
					run("Close");
					run("Set Scale...", "distance=11.6210 known=1 pixel=1 unit=µm"); // setting of scale, CHECK THAT THE SAME SCALE APPLIES TO YOUR IMAGES
					run("Analyze Particles...", "size=100-Infinity pixel circularity=0.00-0.95 exclude clear add");  /*AD HOC FOR FA: analyzes particles with an area of 100 pixels or more (0.7 square microns) 																							
																												      and a circularity of 0-0.95 (exclusion of perfectly circular shapes) except for particle at the edge of the image*/
					//opens original image in HiLo and overlay the ROIs before showing the message
					open(list[i]);
					setSlice(7);
					run("HiLo");
					roiManager("Show All without labels");
			
					waitForUser ("I'm not perfect!", "Please, check the ROI list for any spurious particles and delete them, then click 'OK'"); //human check
					
					selectWindow("ROI Manager");
					roiManager("Select All");
					roiManager("Save", ""+ROISets+"\\ROISet "+image_title+".zip");
					selectWindow("ROI Manager");
					run("Close");
					selectImage(1);
					close();
					selectImage(1);
					close();
				} else {		// if the opened file is a folder, it closes it
					print("Beep Boop");
				}
			}
	}
	
	if (boolean==0) {

		open();			// opening of file to segment
		image_title = getTitle();
		image_directory = getDirectory("image");
		ROISets = image_directory + File.separator + "ROI Sets";
		
		if (!File.exists(ROISets)) {
			File.makeDirectory(image_directory + File.separator + "ROI Sets");
			}
		
		run("Duplicate...", "duplicate channels=7");	// duplication of channel 7 for analysis
		selectImage(1);	//selects the original image
		close(); 	//closes the original image

		// beginning of segmentation
		
       	run("Subtract Background...", "rolling=5 sliding");	//runs Subtract Background with Rolling Ball radius=5.0 pixels (arbitrary value)
		run("Gaussian Blur...", "sigma=2");	//runs Gaussian Blur... filter with a sigma=2 (arbitrary value)
		setAutoThreshold("Default dark");	//sets the thresholding alghorythm to Default and the background to Dark
		run("Threshold...");
		waitForUser ("Manual threshold", "Please, adjust the threshold as desired then press 'Apply' and 'OK'"); // human thresholding
		selectWindow("Threshold");
		run("Close");
		run("Set Scale...", "distance=11.6210 known=1 pixel=1 unit=µm");	// setting of scale, CHECK THAT THE SAME SCALE APPLIES TO YOUR IMAGES
		run("Analyze Particles...", "size=100-Infinity pixel circularity=0.00-0.95 exclude clear add"); // AD HOC FOR FA: analyzes particles with an area of 100 pixels or more (0.7 square microns) and a circularity of 0-0.95 (exclusion of perfectly circular shapes) except for particle at the edge of the image
					
					//opens original image in HiLo and overlay the ROIs before showing the message
		open(image_directory + File.separator + image_title);
		setSlice(7);
		run("HiLo");
		roiManager("Show All without labels");
		
		waitForUser ("I'm not perfect!", "Please, check the ROI list for any spurious particle and delete them, then click 'OK'");
			
		selectWindow("ROI Manager");
		roiManager("Select All");
		roiManager("Save", ""+ROISets+"\\ROISet "+image_title+".zip");
		selectWindow("ROI Manager");
		run("Close");
		selectImage(1);
		close();
		selectImage(1);
		close();
		} 
}


/* "Quick PixFRET" executes the PixFRET plugin, free of human interaction!
 * Before using this macro you need to install Autoclicker, and set the mouse coordinates to those specific to your screen.
 */

macro "Quick PixFRET" {
	
	boolean = getBoolean("Am I working on a folder of images or a single image?", "Folder", "Single image");
	
	if (boolean==1) {

		image_directory = getDirectory("Choose a directory");
		list = getFileList(image_directory);
		
		stacks = image_directory + File.separator + "Stacks";
			if (!File.exists(stacks)) {
				File.makeDirectory(image_directory + File.separator + "Stacks");
				}		
		
		FRET_efficiency = image_directory + File.separator + "FRET Efficiency";
			if (!File.exists(FRET_efficiency)) {
				File.makeDirectory(image_directory + File.separator + "FRET Efficiency");
				}
		
		for (i = 0; i < list.length; i++) {
			
				
			if (matches(list[i], ".*\\.(czi|lsm)$")) {  //checks that the file is not a folder (it would jam the code) and if so it executes the rest of the code
				open(list[i]);		// opening of file to be segmented
				image_title = getTitle();

				run("Duplicate...", "duplicate channels=7"); // 2
				selectImage(1);
				run("Duplicate...", "duplicate channels=3"); // 3
				run("Duplicate...", " ");
				selectImage(1);
				close();
				run("Images to Stack", "name=Stack title=[] use");
				run("Save", "save=["+stacks+"\\Stack of "+image_title+".tif]");

				// saturate pixels' removal UPDATE
				
				run("PixFRET...");

				setTool(0);                                          //Rectangle tool 
				beep();                                              //alert the user
				waitForUser("Select a background area, click add, then COMPUTE FRET");
				
				
				selectWindow("FRET Efficiency (%) of Stack of "+image_title+".tif");
				run("Save", "save=["+FRET_efficiency+"\\FRET Efficiency (%) of Stack of "+image_title+".tif]");
				close();
				close();
				close();
				
			} else {
				print("Boop Beep");
			}
	}
	beep();
	}

	if (boolean==0) {

		open();			// opening of file to segment
		image_title = getTitle();
		image_directory = getDirectory("image");
			
		stacks = image_directory + File.separator + "Stacks";
			if (!File.exists(stacks)) {
				File.makeDirectory(image_directory + File.separator + "Stacks");
			}
		
		FRET_efficiency = image_directory + File.separator + "FRET Efficiency";
			if (!File.exists(FRET_efficiency)) {
				File.makeDirectory(image_directory + File.separator + "FRET Efficiency");
				}
		selectImage(1);
		run("Duplicate...", "duplicate channels=7"); // 2
		
		selectImage(1);
		run("Duplicate...", "duplicate channels=3"); // 3
		run("Duplicate...", " ");
		selectImage(1);
		close();
		run("Images to Stack", "name=Stack title=[] use");
		run("Save", "save=["+stacks+"\\Stack of "+image_title+".tif]");


		run("PixFRET...");


		setTool(0);                                          //Rectangle tool 
		beep();                                              //alert the user
		
		waitForUser("Select a background area, click add, then COMPUTE FRET");

		selectWindow("FRET Efficiency (%) of Stack of "+image_title+".tif");
		run("Save", "save=["+FRET_efficiency+"\\FRET Efficiency (%) of Stack of "+image_title+".tif]");
		close();
		close();
		close();
		
	}	

}

/* "Measure FRET" simply opens the FRET Efficiency image(s) created by Quick PixFRET and the ROI file created by Segmentation
 *  it sets every pixel outside te ROIs to NaN (NotAValue), and then measures the area, mean value and standard deviation of each ROI.
 *  Later, it saves the measurements in a newly created "Results" folder. The measurement paramenters can be adjusted to your needs.
 */

macro "Measure FRET" {
	
	boolean = getBoolean("Am I working on a folder of images or a single image?", "Folder", "Single image");

		if (boolean==1) {
		
			image_directory = getDirectory("Choose a directory");
			list = getFileList(image_directory);
			ROISets = image_directory + File.separator + "ROI Sets";
			
			FRET_efficiency = image_directory + File.separator + "FRET Efficiency";
			if (!File.exists(FRET_efficiency)) {
				exit("FRET Efficiency folder not found. Execute 'Quick FRET' macro before measuring.");
			} else {
				
				results = image_directory + File.separator + "Results";
				if (!File.exists(results)) {
				File.makeDirectory(image_directory + File.separator + "Results");
				}
 
			
			for (i = 0; i < list.length; i++) {
				if (matches(list[i], ".*\\.(czi|lsm)$")) {  //checks that the file is not a folder (it would jam the code) and if so it executes the rest of the code
					open(list[i]);			
					image_title = getTitle(); 
					close();	
					open(""+FRET_efficiency+"\\FRET Efficiency (%) of Stack of "+image_title+".tif");
					roiManager("Open", ""+ROISets+"\\ROISet "+image_title+".zip");
					
					roiManager("Combine");
					setBackgroundColor(0, 0, 0);
					run("Clear Outside");
	
	
					run("Make Inverse");
					run("Multiply...", "value=0.000");
					run("Divide...", "value=0.000");
					run("Make Inverse");

					run("Set Measurements...", "area mean standard redirect=None decimal=3");
					selectWindow("ROI Manager");
					run("Select All");
					roiManager("Measure");
				
					selectWindow("Results");
					saveAs("Results", ""+results+"\\Results "+image_title+".txt");
					selectWindow("Results");
					run("Close");
					selectWindow("ROI Manager");
					run("Close");
					close();
					
	
				} else {
					print("Beep Boop");
				}
			}		
		}
	}

		if (boolean == 0) {
			open();	
			image_title = getTitle();
			image_directory = getDirectory("image");
			ROISets = image_directory + File.separator + "ROI Sets";
			
			FRET_efficiency = image_directory + File.separator + "FRET Efficiency";
			if (!File.exists(FRET_efficiency)) {
				exit("FRET Efficiency folder not found. Execute 'Quick FRET' macro before measuring.");
			} else {
				
			results = image_directory + File.separator + "Results";
				if (!File.exists(results)) {
				File.makeDirectory(image_directory + File.separator + "Results");
				}
			if (!File.isDirectory(FRET_efficiency + File.separator + image_title)) {	
				open(""+FRET_efficiency+"\\FRET Efficiency (%) of Stack of "+image_title+".tif");
				roiManager("Open", ""+ROISets+"\\ROISet "+image_title+".zip");
					
				roiManager("Combine");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
	
	
				run("Make Inverse");
				run("Multiply...", "value=0.000");
				run("Divide...", "value=0.000");
				run("Make Inverse");

				run("Set Measurements...", "area mean standard redirect=None decimal=3");
				selectWindow("ROI Manager");
				run("Select All");
				roiManager("Measure");
				
				selectWindow("Results");
				saveAs("Results", ""+results+"\\Results "+image_title+".txt");
				selectWindow("Results");
				run("Close");
				selectWindow("ROI Manager");
				run("Close");
				close();
				close();
	
				} else {
					print("Boop Beep");
				}
			}
		}
}
