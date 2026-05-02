let sosAlarmAudio = null;
let soundEnabled = false;

export function enableSosAlarmSound() {
  if (!sosAlarmAudio) {
    sosAlarmAudio = new Audio("/sounds/sos-alarm.mp3");
    sosAlarmAudio.volume = 1.0;
  }

  soundEnabled = true;

  // Try to unlock browser audio after a user click.
  sosAlarmAudio
    .play()
    .then(() => {
      sosAlarmAudio.pause();
      sosAlarmAudio.currentTime = 0;
    })
    .catch((error) => {
      console.warn("SOS sound unlock failed:", error);
    });
}

export function playSosAlarmSound() {
  if (!soundEnabled || !sosAlarmAudio) {
    console.warn("SOS sound is not enabled yet.");
    return;
  }

  sosAlarmAudio.currentTime = 0;

  sosAlarmAudio.play().catch((error) => {
    console.warn("SOS alarm sound blocked by browser:", error);
  });
}

export function stopSosAlarmSound() {
  if (!sosAlarmAudio) return;

  sosAlarmAudio.pause();
  sosAlarmAudio.currentTime = 0;
}

export function isSosAlarmSoundEnabled() {
  return soundEnabled;
}