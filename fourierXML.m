%This function will compute a low-pass filtering of an input function,
%using a Fourier transform

%Parameter toolNames: A cell array of the tools used in the experiment
%Parameter fileName: The name of the xml file data to smooth

%Return DS: A cell array of the fourier low-passed data for each tool
function DS = fourierXML(toolNames,fileName)

%Delete all procedures from the Procedures folder
o = Organizer();
o.deleteAll('Procedure');
o.deleteAll('Task');
o.deleteAll('Skill');

%Create a parameter collection object to store the filtering parameters
PC = ParameterCollection();

%First, read the xml file, and convert to procedures
D = xmlToText2(toolNames,fileName);

%A cell array of smoothed data
DS = cell(size(D));
%Iterate over all tools and kalman filter the data, write to file
for i=1:length(D)
    DS{i} = D{i}.fourier(PC.get('Fourier'));
    writeRecord(DS{i});
end%for

%Create a cell array of procedure number to which the smoothed data is
%written
procNums = cell(size(D));
for i=1:length(D)
    procNums{i} = i;
end%for

%Finally, read these records and save to an xml file
DS = textToXML([fileName, '_Fourier'],toolNames,procNums);