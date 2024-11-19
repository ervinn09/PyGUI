function plotPacketLoss(deg, fs, errFlag)

t = (0:length(deg)-1)/fs;
xwin = hann(0.02*fs);
[s,f,tWin] = spectrogram(deg,xwin,length(xwin)*0.9,[],fs);


ax(1) = subplot(211);
imagesc(tWin,f/1000,log10(abs(s)+1e-3))
hold on
plot(t,errFlag*23, 'r')
set(gca,'Ydir','Normal')
ylabel('Frequency [kHz]')
xlabel('Time [s]')

ax(2) = subplot(212);
plot(t,deg)
hold on
plot(t,errFlag * max(abs(deg)), 'r')
ylabel('Amplitude')
xlabel('Time [s]')

linkaxes(ax, 'x')

end
