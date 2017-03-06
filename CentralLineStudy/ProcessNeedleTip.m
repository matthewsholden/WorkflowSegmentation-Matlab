
NeedleTipToNeedle = [ 1 0 0 102.2606; 0 1 0 1.5588; 0 0 1 -9.7013; 0 0 0 1 ];
inTools = { 'LeftHandToReference', 'RightHandToReference', 'NeedleToReference' };
outTools = { 'LeftHandToReference', 'RightHandToReference', 'NeedleTipToReference' };

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject01.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject01_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject02.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject02_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject03.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject03_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject04.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject04_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject05.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject05_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject06.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject06_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject07.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject07_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject08.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject08_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject09.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject09_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject10.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject10_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject11.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject11_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject12.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject12_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject13.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject13_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject14.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject14_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject15.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject15_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject16a.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject16a_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject16b.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject16b_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject17.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject17_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject18.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject18_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject19.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject19_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject20.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\subject20_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_1.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_1_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_2.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_2_NeedleTip.xml', outTools );

Data = AscTrackToData( 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_3.xml', inTools );
NeedleData = Data{3};
NeedleData = NeedleData.calibration( eye(4), NeedleTipToNeedle );
Data{3} = NeedleData;
DataToAscTrack( Data, 'S:\data\PerkTutor\CentralLineStudy\CentralLineOSCE\2014-02-24_NeedleTipData\demo_3_NeedleTip.xml', outTools );
