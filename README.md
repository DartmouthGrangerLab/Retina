# Retina
This code is a translated and enhanced version of c++ code by:  
Alexandre Benoit (benoit.alexandre.vision@gmail.com), LISTIC lab, Annecy le vieux, France (maintained by Listic lab www.listic.univ-savoie.fr and Gipsa Lab www.gipsa-lab.inpg.fr)

See:  
Benoit A., Caplier A., Durette B., Herault, J., "USING HUMAN VISUAL SYSTEM MODELING FOR BIO-INSPIRED LOW LEVEL IMAGE PROCESSING", Elsevier, Computer Vision and     Image Understanding 114 (2010), pp. 758-773, DOI: http://dx.doi.org/10.1016/j.cviu.2010.01.011
  
  
This code is meant to model human retina and V1 visual cortex processing. The retina code does low level processing on video inputs, taking into account the spatial and temporal properties of different retinal cell layers, and outputting two information channels: 
* Parvocellular channel which does detail extraction
* Magnocellular channel which does motion analysis
The V1 code (imageLogPolProjection file) further processes this output by doing frequency and orientation analysis in the log polar domain.

To use, construct Retina object, and call Retina's run method on input video, frame by frame. After calling run on a single frame, get parvo-processed output frame through Retina's getParvo method, and get magno-processed output frame through Retina's getMagno method.

An example is given in the TestRetinaCode file. The Int6.avi file is a test video that can be used with TestRetinaCode.
