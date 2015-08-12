ArrayList<Mover> entities;
Mover leader;
PVector s1,s2,s3,s4,bias;
ArrayList<PVector> grid;
float r, g, b, alpha, speed, lineWidth, min, max, maxvel, maxforce;
int lifespan, liferange, timer, tmean, tsd, target, spawner, spawntime, spawnSize;
boolean paused;

void setup(){
  frameRate(60);
  size(800, 600);
  background(0);
  ellipseMode(CENTER);
  leader = new Mover( width/2, height/2, 0, 255, 255, 255, 20, 0.8, 0.02 );
  s1 = new PVector(width/2,height/2);
  s2 = new PVector(width/2,height/2);
  s3 = new PVector(width/2,height/2);
  s4 = new PVector(width/2,height/2);
  bias = new PVector( 0, 0 );
  entities = new ArrayList<Mover>();
  grid = new ArrayList<PVector>();
  for( int i = 2 ; i < 9 ; i++ ){
    for( int j = 2 ; j < 9 ; j++ ){
      grid.add(new PVector( width * 0.1 * i, height * 0.1 * j ) );
    }
  }
  target = int(random(grid.size()));
  setParameters();
  lifespan = 600;
  liferange = 300;
  timer = 20;
  tmean = 60;
  tsd = 5;
  spawntime = 24;
  spawner = 0;
  min = 0.4;
  max = 4;
  maxvel = 6;
  maxforce = 0.02;
  paused = false;
  spawnFollowers();
}

class Mover{
  PVector[] pos;
  PVector vel, acc, col;
  float maxvel, maxforce, scale;
  int life, curr, prev, maxlife;
  Mover( float x, float y ){
    this( x, y, 60 );
  }
  Mover( float x, float y, int life ){
    this( x, y, life, random(256),random(256),random(256) );
  }
  Mover( float x, float y, int life, float r, float g, float b ){
    this( x, y, life, r, g, b, 1 );
  }
  Mover( float x, float y, int life, float r, float g, float b, float scale ){
    this( x, y, life, r, g, b, scale, 40, 0.4 );
  }
  Mover( float x, float y, int life, float r, float g, float b, float scale, float maxvel, float maxforce ){
    pos = new PVector[3];
    for( int i = 0 ; i < pos.length ; i++ ){
      pos[i] = new PVector( x, y );
    }
    prev = curr = 0;
    vel = new PVector( 0, 0 );
    acc = new PVector( 0, 0 );
    col = new PVector( r, g, b );
    this.life = maxlife = life;
    this.maxvel = maxvel;
    this.maxforce = maxforce;
    this.scale = scale;
  }
  
  PVector position(){
    return pos[curr];
  }
  
  void restore(){
    life = maxlife;
  }
  
  void applyForce( PVector f ){
    acc.add( f );
  }

  void findTarget( PVector target ){
    PVector des = PVector.sub( target, pos[curr] );
    des.normalize();
    des.mult(maxvel);
    PVector steer = PVector.sub( des, vel );
    steer.limit(maxforce);
    applyForce( steer );
  }

  void update(){
    prev = curr;
    curr = ( curr + 1 ) % pos.length;
    vel.add(acc);
    pos[curr].set(PVector.add( pos[prev], vel));
    acc.mult(0);
  }

  boolean display(){
    float alpha = map(life, 0, maxlife, 0, 255);
    stroke(col.x, col.y,col.z, alpha);
    strokeWeight(scale*(abs(vel.x)+abs(vel.y)));
    fill(col.x*0.9,col.y*0.9,col.z*0.9,alpha);
    int i = curr, j;
    do {
      j = (i + 1) % pos.length;
      line(pos[i].x, pos[i].y, pos[j].x, pos[j].y);
      i = j;
    } while ( i != prev );
    ellipse(pos[curr].x, pos[curr].y,(vel.x+vel.y)*scale,(vel.x+vel.y)*scale);
    life--;
    return life > 0;
  }
}

void setParameters(){
  r = map(leader.position().x, 0, width, 20, 250);
  b = map(leader.position().y, 0, height, 20, 250);
  g = dist( leader.position().x, leader.position().y, width/2, height/2 );
  g = constrain( g, 20, 250 );
  speed = dist( pmouseX, pmouseY, mouseX, mouseY );
  alpha = map( speed, 20, 0, 100, 255 );
  lineWidth = map( speed, 0, 15, 12.5, 1 );
  lineWidth = constrain( lineWidth, 0, 5 );  
}

void drawMouse(){
  background( r/2, g/2, b/2 );
  fill( r, g, b, alpha*spawner/spawntime );
  stroke(r, g, b, alpha*spawner/spawntime);
  strokeWeight(lineWidth);

  line(mouseX,pmouseY,mouseX,mouseY);
  line(width/2+(width/2-pmouseX), pmouseY, width/2+(width/2-mouseX),mouseY);
  line(pmouseX, height/2+(height/2-pmouseY), mouseX,height/2+(height/2-mouseY));
  line(width/2+(width/2-pmouseX), height/2+(height/2-pmouseY), width/2+(width/2-mouseX),height/2+(height/2-mouseY)); 
}

void drawPrey(){
  leader.findTarget( grid.get(target) );
  leader.update();
  leader.display();
  leader.restore();
  timer--;
  if( timer < 0 ){
    target = int(random(grid.size()));
    timer = int(random(tsd)) + tmean;
  } 
}

void addFollower( PVector p, float scale ){
    entities.add( new Mover(p.x, p.y, lifespan+( int(random(liferange*2))-liferange ), r, g, b, scale, maxvel, maxforce ) );
}

void spawnFollowers(){
  ellipse( s1.x, s1.y, spawnSize, spawnSize );
  ellipse( s2.x, s2.y, spawnSize, spawnSize );
  ellipse( s3.x, s3.y, spawnSize, spawnSize );
  ellipse( s4.x, s4.y, spawnSize, spawnSize );

  spawner--;
  if( spawner < 0 ){
    spawner = spawntime;
    float x = random( width );
    float y = random( height );
    s1.set( x, y );
    s2.set( width/2 + (width/2-x), y );
    s3.set( x, height/2 + (height/2-y) );
    s4.set( width/2 + (width/2-x), height/2 + (height/2-y) );
    addFollower( s1, max );
    addFollower( s2, max );
    addFollower( s3, max );
    addFollower( s4, max );
    addFollower( new PVector( mouseX, mouseY ), min );
    addFollower( new PVector( width/2+(width/2-mouseX), mouseY ), min );
    addFollower( new PVector( mouseX, height/2+(height/2-mouseY) ), min );
    addFollower( new PVector( width/2+(width/2-mouseX), height/2+(height/2-mouseY) ), min );
  }
}

void drawFollowers(){
  Mover m;
  int t;
  for( int i = entities.size()-1 ; i >= 0 ; i-- ){
    m = entities.get(i);
    t = int(random(grid.size()));
//    m.findTarget(grid.get(t));
    m.findTarget( leader.position() );
    m.applyForce( bias );
    m.update();
    if( !m.display() ){  entities.remove(i); }
  }
}

void draw(){
  if( !paused ){
    setParameters();
    drawMouse();
    spawnFollowers();
    drawFollowers();
    drawPrey();
  }
}

void mouseClicked(){
  paused = !paused;
}

void mouseMoved(){
  maxvel = map( mouseX, 0, width, 0, 200 );
  maxforce = map( mouseY, 0, height, 0, 10 );
}

