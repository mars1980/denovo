//2013 Dequin Sun, Yin Liu, Manuela Donoso, Crys Moore
//Capacitive Sensing as a simple on/off switch
//
//ARDUINO CODE 				
int counter; 					
int finger =0; 					
int savedTime;
int led = 13;					

void setup() { 					

  pinMode(2, OUTPUT);  				
  pinMode(7,INPUT); //all pins are actually in default input pins 
  pinMode(led,OUTPUT);		
  Serial.begin(9600);  				

} 					
void loop() 					

{ 					
  counter=0; 					
  digitalWrite(2,HIGH);  				
  while(!digitalRead(7)){ //while digital pin 7 is still zero, i.e. 		
    //pin 7 is catching up on the signal becoz human body is a capacitor 	
    counter++; 					
  }; 					

  digitalWrite(2,LOW);
  delay(10); 					
 // Serial.println(counter); 				


  if(counter > 15) { 				
    finger =1; 					
    savedTime=millis();
     digitalWrite(led,LOW); 
         Serial.println(finger); 				
				
 				
  } 					

  int passedTime=millis()-savedTime; 			
  if (passedTime>200)  //as soon as finger turn 1, it will stay 1 for the next 50 milliseconds
  { 					
    finger=0; 
      digitalWrite(led,HIGH); 
          Serial.println(finger); 				
				
					
  }
					

} 					

