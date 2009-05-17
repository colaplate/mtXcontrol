import processing.serial.*;

class Arduino {
  int BAUD_RATE  = 14400;
  
  int CRTL  = 255;
  int RESET = 255;

  int WRITE_FRAME  = 253;
  int WRITE_EEPROM = 252;
  int READ_EEPROM  = 251;

  int SPEED = 249;
  int SPEED_INC = 128; //B1000 0000
  int SPEED_DEC = 1;   //B0000 0001

    Serial port;

  public boolean standalone = true;

  Arduino(PApplet app) {
    try {
      port = new Serial(app, Serial.list()[0], BAUD_RATE);
    }
    catch( Exception e) {
      port = null;
    }
    standalone = true;
  }


  /* +++++++++++++++++++++++++++ */

  void write_frame(Matrix matrix) {
    if(standalone) return;
    print("Start Writing Frame - ");
    command( WRITE_FRAME );

    for(int y=0; y<matrix.numY; y++) {
      send(matrix.current_row(y));
    }
    println("Done");
  }

  void write_matrix(Matrix matrix) {
    print("Start Writing Matrix - ");
    command( WRITE_EEPROM );
    send(matrix.numFrames());
    send(matrix.numY);

    for(int f=0; f< matrix.numFrames(); f++) {
      for(int y=0; y<matrix.numY; y++) {
        send(matrix.row(f,y));
      }
      delay(10);
    }
    println("Done");
  }

  Matrix read_matrix() {
    print("Start Reading Matrix - ");
    command( READ_EEPROM );
    int frames = wait_and_read_serial();   
    println( "Frames:" + frames);
    int numY  = wait_and_read_serial();
    Matrix matrix = new Matrix(5, numY);
    
    println( "Rows: " + numY);
    for( int frame_nr = 0; frame_nr < frames; frame_nr++ ) 
    {      
      println("Frame Nr: " + frame_nr);
      String[] data = new String[numY];
      for( int row = 0; row < numY; row++ ) {
        data[row] = Integer.toString(wait_and_read_serial() );
      }
      matrix.add_frame(data);
    }
    println("Done");
    return matrix;
  }

  void toggle(Matrix matrix) {
    if(standalone) {
      standalone = false;
      write_frame(matrix);
      return;
    }
    command(RESET);
    standalone = true;
  }

  void speed_up() {
    if(!standalone) return;
    command(SPEED);
    send(SPEED_INC);
  }

  void speed_down() {
    if(!standalone) return;
    command(SPEED);
    send(SPEED_DEC);
  }

  /* +++++++++++++++++++ */

  private void command( int command ) {
    send(CRTL);
    send(command);
  }

  private void send(int value) {
    if( port == null ) return;
    port.write(value);
  }

  private int wait_and_read_serial() {
    int cnt = 0;
    while( port.available() < 1 ) { delay( 1 ); cnt++;}
    return port.read();
  }
}

