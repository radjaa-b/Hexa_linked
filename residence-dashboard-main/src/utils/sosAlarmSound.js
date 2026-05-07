let soundEnabled = false;

const sounds = {
  sos: null,
  visitor: null,
  maintenance: null,
  contact: null,
};

function createAudio(src, volume = 1.0) {
  const audio = new Audio(src);
  audio.volume = volume;
  return audio;
}

function initializeSounds() {
  if (!sounds.sos) {
    sounds.sos = createAudio("/sounds/sos-alarm.mp3", 1.0);
  }

  if (!sounds.visitor) {
    sounds.visitor = createAudio("/sounds/visitor-request.mp3", 0.8);
  }

  if (!sounds.maintenance) {
    sounds.maintenance = createAudio("/sounds/maintenance-request.mp3", 0.8);
  }

  if (!sounds.contact) {
    sounds.contact = createAudio("/sounds/contact-admin.mp3", 0.8);
  }
}

export function enableSosAlarmSound() {
  initializeSounds();
  soundEnabled = true;

  // Unlock browser audio permission by briefly playing/pausing each sound.
  Object.values(sounds).forEach((audio) => {
    if (!audio) return;

    audio
      .play()
      .then(() => {
        audio.pause();
        audio.currentTime = 0;
      })
      .catch((error) => {
        console.warn("Notification sound unlock failed:", error);
      });
  });
}

export function playSosAlarmSound() {
  playNotificationSound("sos");
}

export function playNotificationSound(type) {
  if (!soundEnabled) {
    console.warn("Notification sounds are not enabled yet.");
    return;
  }

  initializeSounds();

  const audio = sounds[type];

  if (!audio) {
    console.warn(`Unknown notification sound type: ${type}`);
    return;
  }

  audio.currentTime = 0;

  audio.play().catch((error) => {
    console.warn(`${type} notification sound blocked by browser:`, error);
  });
}

export function stopSosAlarmSound() {
  if (!sounds.sos) return;

  sounds.sos.pause();
  sounds.sos.currentTime = 0;
}

export function isSosAlarmSoundEnabled() {
  return soundEnabled;
}