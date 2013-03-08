%This function will produce the results for the trials we have not yet
%accomplished...

%Parameter itr: The number of iterations over which we want to average the
%segmentation

%Return status: Whether or not we have completed the function
function data = segmentTrialReal(itr)

%Assume that if no parameter is provided the user wishes to do only one
%iteration per value
if (nargin < 1)
    itr = 1;
end

%A matrix of the data [type amplitude accuracy]
%(Number procedures per subject * number groups * number algorithms,
%number subjects + number labels)
data = zeros(8*2*2,41+1);


%Practice1, VR
disp('Practice1, Virtual Reality, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice1','VR','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(1,1) = 1;
data( 1:2, 2:( 1 + size(acc,2) ) ) = acc;


%Practice2, VR
disp('Practice2, Virtual Reality, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice2','VR','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(3,1) = 1;
data( 3:4, 2:( 1 + size(acc,2) ) ) = acc;


%Practice3, VR
disp('Practice3, Virtual Reality, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice3','VR','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(5,1) = 1;
data( 5:6, 2:( 1 + size(acc,2) ) ) = acc;


%Practice4, VR
disp('Practice4, Virtual Reality, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice4','VR','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(7,1) = 1;
data( 7:8, 2:( 1 + size(acc,2) ) ) = acc;


%Trial1, VR
disp('Trial1, Virtual Reality, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial1','VR','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(9,1) = 1;
data( 9:10, 2:( 1 + size(acc,2) ) ) = acc;


%Trial2, VR
disp('Trial2, Virtual Reality, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial2','VR','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(11,1) = 1;
data( 11:12, 2:( 1 + size(acc,2) ) ) = acc;


%Trial3, VR
disp('Trial3, Virtual Reality, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial3','VR','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(13,1) = 1;
data( 13:14, 2:( 1 + size(acc,2) ) ) = acc;


%Trial4, VR
disp('Trial4, Virtual Reality, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial4','VR','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(15,1) = 1;
data( 15:16, 2:( 1 + size(acc,2) ) ) = acc;




%Begin the control group analysis (this should be a little bit faster
%because there are fewer members in the control group here...)



%Practice1, Control
disp('Practice1, Control, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice1','Control','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(17,1) = 1;
data( 17:18, 2:( 1 + size(acc,2) ) ) = acc;


%Practice2, Control
disp('Practice2, Control, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice2','Control','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(19,1) = 1;
data( 19:20, 2:( 1 + size(acc,2) ) ) = acc;


%Practice3, Control
disp('Practice3, Control, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice3','Control','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(21,1) = 1;
data( 21:22, 2:( 1 + size(acc,2) ) ) = acc;


%Practice4, Control
disp('Practice4, Control, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Practice4','Control','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(23,1) = 1;
data( 23:24, 2:( 1 + size(acc,2) ) ) = acc;


%Trial1, Control
disp('Trial1, Control, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial1','Control','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(25,1) = 1;
data( 25:26, 2:( 1 + size(acc,2) ) ) = acc;


%Trial2, Control
disp('Trial2, Control, L3-4');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial2','Control','L3-4',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(27,1) = 1;
data( 27:28, 2:( 1 + size(acc,2) ) ) = acc;


%Trial3, Control
disp('Trial3, Control, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial3','Control','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(29,1) = 1;
data( 29:30, 2:( 1 + size(acc,2) ) ) = acc;


%Trial4, Control
disp('Trial4, Control, L4-5');

%Return the accuracy of the segmentation
acc = segmentSubtrialReal('Trial4','Control','L4-5',itr);

%Display the parameters
disp([ '  Accuracy (mean): ', num2str(mean(acc,2)') ]);
disp([ '  Accuracy (standard deviation): ', num2str(std(acc,1,2)') ]);
acc

%Write to matrix
data(31,1) = 1;
data( 31:32, 2:( 1 + size(acc,2) ) ) = acc;


%Finally, write our matrix of data to file
dlmwriten('TrialRealData',data,'\t');
