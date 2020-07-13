clear
close all
clc

rng(0);

addpath('C:\Users\gxs160730\Documents\Ph.D\CNN-SE\CNN-VAD\Training Code\Functions\');

%%Parameters
params.fs               = 48000;
params.fs2              = 8000;
params.overlap          = 384*2;
params.frameSize        = 2*params.overlap;
params.overlap_dec      = params.overlap * params.fs2/params.fs;
params.frameSize_dec    = 2*params.overlap_dec;
params.nfft             = 256;
params.maxN             = params.overlap_dec*floor(params.fs2*10/params.overlap_dec);
params.window           = hanning(params.frameSize_dec);
params.snr              = [0] ;

%% Audio Files
[data.noiseFiles, data.speechFiles] = getData_g();
data.nSpeechFiles = numel(data.speechFiles);
data.nNoiseFiles  = numel(data.noiseFiles);
trainData         = cell(length(params.snr)*data.nNoiseFiles*data.nSpeechFiles,1);
trainData_1       = cell(data.nSpeechFiles,1);

count=0;
% Feature Generation
% for snr_cnt = 1:length(params.snr)
% snr_val = params.snr(snr_cnt);

%NOISY SPEECH GENERATION
tic;
for n = 1:data.nNoiseFiles
    noiseFile           = [data.noiseFiles(n).folder '\' data.noiseFiles(n).name];
    [noiseSig_2,fs_n]   = audioread(noiseFile);
    noiseSig_1          = [noiseSig_2;noiseSig_2;noiseSig_2;noiseSig_2];
    noiseSig            = resample(noiseSig_1,params.fs2,fs_n);
    for s=1:data.nSpeechFiles
        %             count=count+1;
        speechFile             = [data.speechFiles(s).folder '\' data.speechFiles(s).name];
        [speechSig_2,fs_s]     = audioread(speechFile);
        %nsg.speechSig_2 = nsg.speechSig_2(:,2);
        speechSig_1            = [speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2;speechSig_2];
        speechSig              = resample(speechSig_1,params.fs2, fs_s);
        clean_sig              = speechSig(1:12*params.fs2,:);
        noise_sig              = noiseSig(1:12*params.fs2,:);
        %[noisySig,noise_segment]  = addnoise_asl_nseg(clean_sig,params.fs2,16,noise_sig,params.fs2,16, params.snr);
        [noisySig]  = addnoise(clean_sig,noise_sig,params.snr, params.fs2);

        %LOG POWER SPECTRA GENERATION FOR NOISY SPEECH
        audioFrames     = reshape(noisySig, params.overlap_dec, []);
        procFrames      = params.window .* [audioFrames(:,1:end-1); audioFrames(:,2:end)];
        procFFT         = fft(procFrames, params.nfft);
        mag_procFFT     = abs(procFFT);
        ang_procFFT     = angle(procFFT);
        STFTMdb1        = 20*log(mag_procFFT);
        STFTMdb         = STFTMdb1(1:params.nfft/2+1,:);

        %LOG POWER SPECTRA GENERATION FOR CLEAN SPEECH(CS)
        audioFrames_CS  = reshape(clean_sig(:,1), params.overlap_dec, []);
        procFrames_CS   = params.window .* [audioFrames_CS(:,1:end-1); audioFrames_CS(:,2:end)];
        procFFT_CS      = (fft(procFrames_CS, params.nfft));
        
        mag_procFFT_CS  = abs(procFFT_CS);
        ang_procFFT_CS  = angle(fft(procFrames_CS, params.nfft));
        STFTMdb1_CS     = 20*log(mag_procFFT_CS);
        STFTMdb_CS      = STFTMdb1_CS(1:params.nfft/2+1,:);
        trainData_1(s)              = {[STFTMdb',...
                                        STFTMdb_CS' , n*s*ones(size(STFTMdb_CS(1,1:end)))']};
    end
     trainData(count+1:n*data.nSpeechFiles,1)          = trainData_1;
     count = count + data.nSpeechFiles;
     disp('Loopdone');
end

% end
filename = ['C:\Users\gxs160730\Documents\Ph.D\CNN-SE\CNN-VAD\Features\Training\LPS\MACHINERY\DUMMY\HINT_test_M_0'];
save(filename,'trainData','-v7.3');
% disp('Done');
k = toc