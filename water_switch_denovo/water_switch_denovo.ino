//Arduino Version 1.0.3
//works w/ Processing sketch 'denovo'
//Dequin Sun, Yin Liu, Manuela Donoso, Crys Moore 2013
//circuit diagram:
//DIGITAL 7 ------------+
//                      |--------OBJECT
//                      |
//                     [R=1Mohm]
//                      |
//                      |
//DIGITAL 2 ------------+

int counter; 					
int finger =0; 					
int savedTime;
int led = 13;
int calibration =15;					

void setup() { 					
  Serial.begin(9600); 
  pinMode(2, OUTPUT);  				
  pinMode(7,INPUT); //all pins are actually in default input pins 
  pinMode(led,OUTPUT);		
   				

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
  if(counter > calibration) 
  { 				
    finger =1; 					
    savedTime=millis();
    digitalWrite(led,HIGH); 
    Serial.println(finger); 							
  } 					

  int passedTime=millis()-savedTime; 			
  if (passedTime>200)  //as soon as finger turn 1, it will stay 1 for the next 50 milliseconds
  { 					
    finger=0; 
    digitalWrite(led,LOW); 
    Serial.println(finger); 				
  }
}
