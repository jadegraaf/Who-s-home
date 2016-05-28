//
//  photon-code.c
//  This code runs on the lamp device itself and it flashed through the https://build.particle.io portal
//
//  Created by Joeri de graaf on 29-05-16.
//  Copyright © 2016 Joeri de graaf. All rights reserved.
//

// User identifiers
#define joeri   0
#define maya    1
#define bart    2

// Array of Led pins assigned to each user
int ledPin[3] = {D0, D1, D2};

// Home state of each user
// TODO: rewrite stuff to bool HomeState[] = {false, false, false};
bool joeriHomeState = false;
bool mayaHomeState  = false;
bool bartHomeState  = false;

// Makes sure the lights only light up between 17:00 and 0:00 if someone is home
bool lampModeEnabled = false;

// Ignores whether it is evening or not, lights will turn on
bool demoMode = true;

void setup()
{
  // Initialize all the led pins
  for (int pin = 0; pin <= 2; pin++) {
    pinMode(ledPin[pin], OUTPUT);
  }
  
  delay(500);
  
  // Fade-on all the lights
  for (int fadeValue = 0; fadeValue <= 255; fadeValue+=5) {
    for (int pin = 0; pin <= 2; pin++) {
      analogWrite(ledPin[pin], fadeValue);
    }
    delay(20);
  }
  
  // Halt the program untill a cloud connection is made or the time won't be synchronized
  while (!Particle.connected()){}
  
  delay(1000);
  
  // Fade-off all lights to off once connected
  for (int fadeValue = 255; fadeValue >= 0; fadeValue-=5) {
    for (int pin = 0; pin <= 2; pin++) {
      analogWrite(ledPin[pin], fadeValue);
    }
    delay (25);
  }
  
  // Set the correct time zone
  Time.zone(2);
  
  // Disable the LED
  RGB.control(true);
  RGB.brightness(0);
  
  // Boot up message
  Particle.publish("Connected", PRIVATE);
  
  // Register the exposed functions
  Particle.function("changeState", changePersonHomeStatus);
  Particle.function("getState", getFamilyHomeStatus);
  Particle.function("setState", setFamilyHomeStatus);
  
  Particle.function("doSequence", doSequence);
  
  // Determine if the lights should be allowed to turn on or stay of based on the boot time
  if (Time.hour() > 18) {
    lampModeEnabled = true;
  }
}

void loop()
{
  if (demoMode)
    return;
  
  // At the start of the evening, turn on the lights of who's home in a randomised way
  if (Time.hour() == 18 && Time.minute() == 00 && !lampModeEnabled) {
    lampModeEnabled = true;
    
    // Turn on the lights in random order
    doSequence("on");
  }
  
  // At the end of the evening, turn off all lights
  if (Time.hour() == 0 && Time.minute() == 0 && lampModeEnabled) {
    lampModeEnabled = false;
    
    // Turn off all lights in random order
    doSequence("off");
    
    // Set everyones status to false
    joeriHomeState = false;
    mayaHomeState = false;
    bartHomeState = false;
  }
}

// Triggered when a person arrives home
// Returns true for a succesfull change and false on error
int changePersonHomeStatus(String command) {
  int person  = command.charAt(0);
  int state   = command.substring(1).toInt();
  
  switch (person) {
    case 'J':
      // Make sure the light is not already that state
      if (joeriHomeState != state) {
        joeriHomeState = (bool)state;
        
        if (lampModeEnabled || demoMode)
          changeLightState(joeri, state);
        
        Particle.publish("Joeri changed state", PRIVATE);
        return true;
      }
      return false;
    case 'M':
      if (mayaHomeState != state) {
        mayaHomeState = (bool)state;
        
        if (lampModeEnabled || demoMode)
          changeLightState(maya, state);
        
        Particle.publish("Maya changed state", PRIVATE);
        return true;
      }
      return false;
    case 'B':
      if (bartHomeState != state) {
        bartHomeState = (bool)state;
        
        if (lampModeEnabled || demoMode)
          changeLightState(bart, state);
        
        Particle.publish("Bart changed state", PRIVATE);
        return true;
      }
      return false;
    default:
      Particle.publish("Invalid data recieved", command, PRIVATE);
      return false;
  }
}

// Returns 3 bits representing the state of the 3 members
int getFamilyHomeStatus(String command) {
  return ((joeriHomeState * 100) + (mayaHomeState * 10) + (bartHomeState));
}

// Sets all statuses in one go for debugging
int setFamilyHomeStatus(String command) {
  // int states = command.substring(0,1).toInt();
  
  joeriHomeState =command.substring(0,1).toInt();
  mayaHomeState = command.substring(1,2).toInt();
  bartHomeState = command.substring(2,3).toInt();
  
  int lightState[3] = {joeriHomeState, mayaHomeState, bartHomeState};
  
  for (int i = 0; i <= 2; i++) {
    if (lightState[i]) {
      analogWrite(ledPin[i], 255);
    }
  }
  
  return getFamilyHomeStatus("");
}

// Changes the state of [pin] to reflect the [state]
void changeLightState(int person, bool state) {
  // Determings how quickly the light will change from state to !state
  int lightSpeed = random(30, 70);
  
  if (state) {
    for( int fadeValue = 0; fadeValue <= 255; fadeValue += 5) {
      analogWrite( ledPin[person], fadeValue);
      delay(lightSpeed);
    }
    Particle.publish("Light switched on", String(person), PRIVATE);
  }
  else {
    for( int fadeValue = 255; fadeValue >= 0; fadeValue -= 5) {
      analogWrite( ledPin[person], fadeValue);
      delay(lightSpeed);
    }
    Particle.publish("Light switched off", String(person), PRIVATE);
  }
}

int doSequence(String command) {
  int shuffledArray[3] = {D0, D1, D2};
  int lightState[3] = {joeriHomeState, mayaHomeState, bartHomeState};
  
  for (int i = 0; i <= 2; i++)
  {
    int r = random(0, 3-i);
    
    int t1 = shuffledArray[i];
    shuffledArray[i] = shuffledArray[r];
    shuffledArray[r] = t1;
    
    int t2 = lightState[i];
    lightState[i] = lightState[r];
    lightState[r] = t2;
  }
  
  if (command == "on") {
    for (int i = 0; i <= 2; i++) {
      if (lightState[i]) {
        changeLightState(shuffledArray[i], lightState[i]);
      }
      delay(random(50, 300));
    }
  }
  else {
    for (int i = 0; i <= 2; i++) {
      if (lightState[i]) {
        changeLightState(shuffledArray[i], 0);
      }
      delay(random(50, 300));
    }
  }
  return true;
}