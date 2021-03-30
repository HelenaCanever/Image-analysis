/* By Helena Canever, for Borghi Lab "Mechanotransduction: from cell surface to nucleus" @ Institut Jacques Monod. 
 *  Contact at helena.canever@gmail.com
*
*/

// open an .lsm or .czi specral image

open();
image_directory = File.directory ;
image_title = File.name ;

// add here a step that allows to estimate the width of an average contact

  dialog_title = "Specify cell average contact width";
  width=3; 
  Dialog.create("Specify cell average contact width");
  Dialog.addNumber("Width:", width);
  Dialog.addCheckbox("microns", false);
  Dialog.show();
  width = Dialog.getNumber();
  microns = Dialog.getCheckbox();
  if (microns)
     width = width;
  else
     toScaled(width);
  

// duplicates channel 7, were a peak of intensity is normally located for TSMod acquisitions

run("Duplicate...", "duplicate channels=7");
selectImage(1);
close();
selectImage(1);

// changes the LUT from grays to HiLo, which visualizes potential spots of signal saturation to avoid in the later steps to avoid spurious measurements

run("HiLo");
setTool("polyline");

// allows the user to manually, but quickly, select the cell-cell contacts to segment

waitForUser("Select all cell contacs using the polyline tool, then select 'OK' ");

// for each selected cell-cell contact, it creates an area selection whose width is that of a cell contact (according to previous estimates)
count = roiManager("count");
for (i = 0; i < count; i++) {

	roiManager("Select", i);
	run("Line to Area");
	run("Enlarge...", "enlarge=" + width);
	roiManager("Update");

}

// saves the new ROI set in the folder of origin of your image and closes all

roiManager("Save", ""+image_directory+"\\ ROISet "+image_title+".zip");

close("*");
selectWindow("ROI Manager");
run("Close");
