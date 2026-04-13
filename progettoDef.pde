//Il seguente progetto permette di:
//1. disegnare un poligono che rappresenta l'ambiente in cui il robot può muoversi
//2. disegnare N poligono interni che rappresentano gli ostacoli presenti all'interno dell'ambiente. Essi sono costruiti nel modo seguente: 
//   non è possibile sovrapporre gli ostacoli, non è possibile disegnare un ostacolo fuori dal suo ambiente. Se i lati di due poligoni si sovrappongono, 
//   il lato responsabile della sovrapposizione verrà eliminato e si ritorna al disegno del poligono precedente che andrà riconfermato.
//3. scelgere un punto iniziale e un punto finale in modo tale che siano entrambi all'interno dell'ambiente ma all'esterno degli ostacoli.
//4. premendo "b", una barra verticale inizierà a muoversi disegnando delle linee verticali in corrispondenza dei vertici di tutti i poligoni. 
//   la barra deve essere confermata con "a".
//5. "f" permette di costruire e visualizzare il grafo teorico.
//6. a questo punto può essere visualizzato il percorso tra punto inziale e punto finale, passante per i punti medi delle celle.
//7. la bspline di grado 3 interpolerà il cammino minimo: se la spline interseca uno degli ostacoli, al termine del percorso verrà visualizzata una spline di 
//   grado 4 per verificare se l'interpolazione migliora. 
 

import java.util.ArrayList;
import javax.swing.JOptionPane;
import java.util.Objects;
import java.util.PriorityQueue;
import java.util.HashMap;

ArrayList<PVector> firstPolygon = new ArrayList<PVector>(); // Lista di vertici del primo poligono
ArrayList<ArrayList<PVector>> polygons = new ArrayList<ArrayList<PVector>>(); // Lista di liste di vertici degli altri poligoni
boolean fillVerticalLines = false;
ArrayList<Linea> lineSegments = new ArrayList<Linea>(); // Lista per memorizzare i segmenti di linee verdi
boolean isDrawingPolygon = true; // Flag per indicare se si sta disegnando un poligono
boolean canDrawPolygons = true; // Flag per indicare se è possibile disegnare nuovi poligoni
boolean isFirstPolygon = true; // Flag per indicare se si sta disegnando il primo poligono
boolean displayPoints = true; // Flag per indicare se visualizzare i punti cliccati
boolean disegno = false;
boolean grafo = false;
boolean grafoVero = false;
ArrayList<PVector> points = new ArrayList<PVector>(); // Lista per memorizzare i punti cliccati
ArrayList<PVector> listaOrdinata = new ArrayList<PVector>(); // Lista ordinata di tutti i vertici dei poligoni
ArrayList<PVector> concavita = new ArrayList<PVector>(); // Lista dei vertici responsabili della concavità 

//variabili barra
int barraX=-2; // Posizione X della barra
int barraY=0; // Posizione Y della barra
int larghezza = 2; // Lunghezza della barra
int altezza; // Altezza della barra
float vel=0; // Velocità di movimento della barra
boolean velocita = false;
boolean barra = false;
ArrayList<Boolean> verticeColpito = new ArrayList<Boolean>(); // Array per tenere traccia dello stato dei vertici (colpito o meno) 
ArrayList<Float> intersectionPoints= new ArrayList<Float>(); // Lista delle coordinate x dei punti di intersezione
ArrayList<Linea> verticali = new ArrayList<Linea>(); // ArrayList per le linee verticali
ArrayList<Linea> lineeConsiderate = new ArrayList<Linea>();


ArrayList<Linea> perimetroP = new ArrayList<Linea>(); // Linee per il perimetro del poligono esterno
ArrayList<Linea> perimetroO = new ArrayList<Linea>(); // Linee per i perimetri dei poligoni interni
ArrayList<Linea> perimetroT = new ArrayList<Linea>();
boolean flg = false;
ArrayList<PVector> intersezioni = new ArrayList<PVector>();
ArrayList<PVector> verticiTot = new ArrayList<PVector>();
ArrayList<Float> ascisseUniche = new ArrayList<Float>();                                                           
ArrayList<ArrayList <PVector>> vertTot = new ArrayList<ArrayList<PVector>>(); //lista di vertici di cui sopra, ma raggruppati per ascissa.
ArrayList<Linea> segmenti = new ArrayList<Linea>(); //sono le linee verticali ma considerando solo i segmenti all'interno del poligono

//punti di inizio e di fine
boolean start; 
boolean end;
PVector startingPoint = new PVector(-10, -10); 
PVector endingPoint = new PVector(-10, -10);

// Variabili per la posizione della grafica
float legendaX, legendaY;
// Variabili per il trascinamento della grafica
boolean isDragging = false;
float offsetX, offsetY;
// Variabile per la visibilità della grafica
boolean legendaVisibile = false;
boolean keyPressedBefore = false;

ArrayList<Integer> indices = new ArrayList<Integer>();
ArrayList<PVector> rimanente = new ArrayList<PVector>();

ArrayList<Nodo> nodes = new ArrayList<Nodo>(); // Lista dei nodi

ArrayList<Float> lenLinea = new ArrayList<Float>();

ArrayList<PVector> middlePoints = new ArrayList<PVector>();
ArrayList<Linea> segmentsTot = new ArrayList<Linea>();
ArrayList<Cell> celle = new ArrayList<Cell>();
ArrayList<ArrayList<Linea>> ad = new ArrayList<ArrayList<Linea>>();
ArrayList<Nodo> nodiCammino = new ArrayList<Nodo>();
ArrayList<Linea> archi = new ArrayList<Linea>();
PVector primoNodo = null;
PVector ultimoNodo = null;
ArrayList<Linea> archiDaPrimo = new ArrayList<Linea>();
ArrayList<Linea> archiPerUltimo = new ArrayList<Linea>();
ArrayList<PVector> puntiSpecial = new ArrayList<PVector>();

boolean cammino = false;
ArrayList<PVector> pathPoints = new ArrayList<PVector>();

int currentSegment = 0;
float t = 0;
boolean move = false;
boolean moving = true; // Variabile di controllo per fermare il movimento
boolean moving4 = true;

float tParam4 = 0;
float tParam = 0; // Parametro temporale per animare il punto
float tStep = 0.05; // Passo temporale per l'animazione

int resolution = 100;
boolean spline = false;
boolean splineQ = false;
boolean scheletro = false;

boolean stop = false; // Stato che indica se la spline di grado 3 è terminata
boolean moveSpline4 = false; // Stato che indica se la spline di grado 4 deve partire

boolean movingSpline3 = false; // Stato per il movimento della spline di grado 3
boolean movingSpline4 = false; // Stato per il movimento della spline di grado 4
boolean splineActive = false; // Stato per attivare/disattivare la spline

PVector intersection = null; //punto di intersezione della spline di grado 3
boolean inter = false; //boolean per far partire la spline di grado 4 

void setup() {
  size(1000, 900); // Imposta le dimensioni della finestra
  
  polygons.add(new ArrayList<PVector>()); // Inizia con un poligono vuoto
}



void draw() {
  background(255); // Sfondo bianco

  // Disegna il primo poligono
  if (firstPolygon.size() > 0) {
    fill(255, 255, 255, 100); // Colore riempimento poligono con trasparenza (bianco)
    stroke(0); // Colore contorno nero
    beginShape();
    for (PVector v : firstPolygon) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }

  
  
  // Disegna tutti gli altri poligoni
  for (ArrayList<PVector> vertices : polygons) {
    if (vertices.size() > 0) {
      PVector concavityVertex = findConcavityVertex(vertices);
      if (concavityVertex == null) {
        fill(150, 150, 250, 100); // Colore riempimento poligono convesso con trasparenza (azzurrino)
      } else {
        fill(150, 150, 250, 150); // Colore riempimento poligono non convesso con trasparenza (rossiccio)
      }
      stroke(0); // Colore contorno nero
      
      beginShape();
      for (PVector v : vertices) {
        vertex(v.x, v.y);
      }
      endShape(CLOSE);
      
      if (concavityVertex != null) {
        //fill(255, 0, 0); // Colore rosso per il vertice concavo
        //ellipse(concavityVertex.x, concavityVertex.y, 5, 5);
        
        boolean aggiunto = false;
        for(PVector p : concavita){
          if(p.x == concavityVertex.x && p.y == concavityVertex.y){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          concavita.add(concavityVertex);
        }
      }
      
    }
  }
  
 
  //Impedisce la sovrapposizione dei poligoni
  ArrayList<PVector> ostacolo = new ArrayList<PVector>();
  if(!polygons.isEmpty()){
    ostacolo = getOverlappingPolygon(polygons);
    if(ostacolo != null){
      removePolygon(polygons, ostacolo);
      removePoints(points, ostacolo);
    }

  }
  
  for(PVector v : firstPolygon){
    boolean trovato = false;
    for(PVector p : listaOrdinata){
      if(v.x == p.x && v.y == p.y){
        trovato = true;
        break;
      }
    }
    if(!trovato){
      listaOrdinata.add(v);
    }
  }
  

  for (int i = 0; i < polygons.size(); i++) {
    ArrayList<PVector> list = polygons.get(i);
    for (int j = 0; j < list.size(); j++) {
      PVector v = list.get(j);
      // Verifica se v è già presente in listaOrdinata
      boolean found = false;
      for (PVector existingVector : listaOrdinata) {
        if (existingVector.x == v.x && existingVector.y == v.y) {
          found = true;
          break;
        }
      }
      // Aggiungi v a listaOrdinata anche se trovato
      if(!found){
        listaOrdinata.add(v);
      }
    }
  }
  
  //Start
  if(isInsidePolygon(startingPoint.x, startingPoint.y, firstPolygon) && !puntoDentroPoligono(startingPoint, perimetroO)){
        stroke(0, 0, 0);
        fill(#4FB746);
        ellipse(startingPoint.x, startingPoint.y, 10, 10);
  }
  
  //end
  if(isInsidePolygon(endingPoint.x, endingPoint.y, firstPolygon) && !puntoDentroPoligono(endingPoint, perimetroO)){
          stroke(0, 0, 0);
          fill(#14F53E);
          ellipse(endingPoint.x, endingPoint.y, 10, 10);
  }
  
  
  
  listaOrdinata = mergeSortX(listaOrdinata);


  //barra che scorre attivata con 'b'
  scorrimento();

  
  strutturaGrafo();
  
  costruzioneGrafoPratico();
  if(scheletro){
    for(Nodo nodo: nodes){
      PVector vertice = nodo.punto;
      stroke(#C42ED8);
      fill(#C42ED8);
      ellipse(vertice.x, vertice.y, 10, 10);
      for (Nodo vicino : nodo.vicini) {
        stroke(#FFCA36); // Linee verdi per connessioni tra nodi
        line(nodo.punto.x, nodo.punto.y, vicino.punto.x, vicino.punto.y);
      }
      
      
    }
  }
  grafoVero();
  
  

   if(cammino){
     camminoMinimo();
   }
   
   // Draw the path
      stroke(#40C157);
      noFill();
      beginShape();
      for (PVector point : pathPoints) {
        vertex(point.x, point.y);
      }
      endShape(); 
      
      if(move){
        // Move along the path
        if (currentSegment < pathPoints.size() - 1) {
          PVector start = pathPoints.get(currentSegment);
          
          
          PVector end = pathPoints.get(currentSegment + 1);
         
          
          currentPosition = PVector.lerp(start, end, t);
          t += 0.06;
          if (t >= 1) {
            t = 0;
            currentSegment++;
          }
        }
        
        // Disegna la posizione corrente
        fill(255, 0, 0);
        noStroke();
        ellipse(currentPosition.x, currentPosition.y, 10, 10);
      }
  
      ArrayList<PVector> pathPoints4 = new ArrayList<PVector>();
      
      for(PVector punto : pathPoints){
        boolean trovato = false;
        for(PVector p4: pathPoints4){
          if(punto.x == p4.x && punto.y==p4.y){
            trovato = true;
            break;
          }
        }
        if(!trovato){
          pathPoints4.add(punto);
        }
      }
      
 // Se la spline di grado 3 è attiva
      if(spline){
        drawBSpline(pathPoints, resolution);
       
        
        // Calcola la posizione del punto animato lungo la curva
        float[] knots = generateKnots(pathPoints.size(), 3);
        PVector movingPoint = deBoor(pathPoints, knots, 3, tParam);
    
        // Disegna il punto che si muove lungo la curva
        fill(255, 0, 0);
        noStroke();
        ellipse(movingPoint.x, movingPoint.y, 10, 10);
        
        intersection = curveIntersectsPerimeter(pathPoints, perimetroO, resolution);
        
        if(intersection != null){
          inter = true;
          fill(0, 0, 255);
          noStroke();
          ellipse(intersection.x, intersection.y, 10, 10);
        }
        
        // Aggiorna il parametro temporale solo se il movimento è abilitato
        if (moving) {
          tParam += tStep;
          if (tParam >= knots[knots.length - 4]) {
            tParam = knots[knots.length - 4]; // Ferma il parametro temporale al valore massimo
            moving = false; // Ferma il movimento
            if(inter && !moving){
              splineQ = true;
               
            }
          }
        }    
       }

      if(splineQ){
        drawBSpline4(pathPoints4, resolution);
         
        // Calcola la posizione del punto animato lungo la curva
        float[] knots = generateKnots4(pathPoints4.size(), 4);
        PVector movingPoint = deBoor4(pathPoints4, knots, 4, tParam4);
    
        // Disegna il punto che si muove lungo la curva
        fill(255, 0, 0);
        noStroke();
        ellipse(movingPoint.x, movingPoint.y, 10, 10);
    
        // Aggiorna il parametro temporale solo se il movimento è abilitato
        if (moving4) {
          tParam4 += tStep*0.5;
          if (tParam4 >= knots[knots.length - 4]) {
            tParam4 = knots[knots.length - 4]; // Ferma il parametro temporale al valore massimo
            moving4 = false; // Ferma il movimento
          }
        }
       }
  
  
  
    // Disegna i punti cliccati solo se displayPoints è true
    if (displayPoints) {
     
        fill(0); // Colore nero per i punti
        noStroke();
        for (PVector point : points) {
         
            ellipse(point.x, point.y, 5, 5); // Disegna un cerchio di diametro 5
          
        }
      
    }
  
  if(disegno){
    fill(255, 0, 0);
    noStroke();
    for(PVector v: verticiTot){
      ellipse(v.x, v.y, 5, 5);
      
    }
  }
  
  if(grafo){
    fill(0, 255, 0);
    noStroke();
    for(PVector v: middlePoints){
      ellipse(v.x, v.y, 5, 5);
      
    }
  }
  
  
  //LEGENDA:
  //Disegna la grafica bianca e visualizza le coordinate se è visibile
  if (legendaVisibile) {
    fill(255); // Colore bianco
    rect(legendaX, legendaY, 300, 600);
    fill(0); // Colore nero per il testo
    // Disegna le coordinate dei vertici
    drawCoordinates();
  }
  
  
}


void mouseClicked() {
  if (isDrawingPolygon && canDrawPolygons) {
    // Aggiungi un nuovo vertice al poligono corrente
    if (isFirstPolygon) {
      firstPolygon.add(new PVector(mouseX, mouseY));
    } else {
      PVector nuovoVertice = new PVector(mouseX, mouseY);
      if(isInsidePolygon(nuovoVertice.x, nuovoVertice.y, firstPolygon) && !puntoDentroPoligono(nuovoVertice, perimetroO)){
        polygons.get(polygons.size() - 1).add(new PVector(mouseX, mouseY)); //<>//
      }
    }
  }
  // Aggiungi il punto cliccato alla lista dei punti solo se canDrawPolygons è true
  if(canDrawPolygons){
    PVector nuovoVertice = new PVector(mouseX, mouseY);
    if (isInsidePolygon(nuovoVertice.x, nuovoVertice.y, firstPolygon) && !puntoDentroPoligono(nuovoVertice, perimetroO)) {
      points.add(nuovoVertice);
    }
  }
  
  //acquisici punti di inizio e fine
  if(!canDrawPolygons && start){
    startingPoint.set(mouseX, mouseY);

    start = false;
  }
  if(!canDrawPolygons && end){
    endingPoint.set(mouseX, mouseY);
    end = false;
  }
}


void drawCoordinates() {
  fill(0);
  textSize(12);
  textAlign(LEFT);
  
  // Disegna il titolo della legenda
    textSize(16);
    text("LEGENDA:", legendaX + 10, legendaY + 20);

    // Disegna le istruzioni
    textSize(12);
    text("Premere 'RIGHT' per disegnare la prossima figura", legendaX + 10, legendaY + 40);
    text("Premere 'ENTER' per confermare l'ambiente", legendaX + 10, legendaY + 60);
    text("Premere 's' e cliccare sulla scena per decidere il punto di partenza", legendaX + 10, legendaY + 80);
    text("Premere 'e' e cliccare sulla scena per decidere il punto di arrivo", legendaX + 10, legendaY + 100);
    text("Premere 'b' per avviare la barra verticale", legendaX + 10, legendaY + 120);
    text("Premere 'a' per visualizzare le celle", legendaX + 10, legendaY + 140);
    text("Premere 'd' visualizzare i punti di intersezione", legendaX + 10, legendaY + 160);
    text("Premere 'f' per visualizzare il grafo teorico", legendaX + 10, legendaY + 180);
    text("Premere 'g' per vedere i nodi pratici", legendaX + 10, legendaY + 200);
    text("Premere 'c' per visualizzare il cammino", legendaX + 10, legendaY + 220);
    text("Premere 'v' per avviare la spline", legendaX + 10, legendaY + 240);
    text("Premere 'q' per avviare la spline di quarto grado", legendaX + 10, legendaY + 260);
 
}

void keyPressed() {
  if(keyCode == 'b' || keyCode == 'B'){
    //La barra inizia a muoversi
    vel = 1;

  } else if(keyCode == 'd' || keyCode == 'D'){
    //disegno dei punti di intersezione delle linee verticali
    disegno = !disegno;
  
  } else if (key == 'a' || key == 'A') {
    // Attiva/disattiva il riempimento delle linee verticali
    fillVerticalLines = !fillVerticalLines;
    
  } else if(keyCode == 'g' || keyCode == 'G'){
    //punti medi dei segmenti: nodi del grafo vero
    grafo = !grafo;  
  
  } else if(keyCode == 'f' || keyCode == 'F'){
    //grafo teorico
    scheletro = !scheletro;
  }
  
  //startingPoint
   else if(keyCode == 'S' || keyCode == 's'){
      start = true;
  }
  
  //ending point
  else if(keyCode == 'E' || keyCode == 'e'){
      end = true;
  }
  else if(keyCode == 'c' || keyCode == 'C'){
    //visualizza il cammino minimo
    cammino=!cammino;
  }
  
 if (key == 'v' || key == 'V') {
    //spline di grado 3
    if (spline) {
        spline = false;
        moving = false;
    } else {
        spline = true;
        tParam = 0; // Reset del parametro temporale
        moving = true; // Avvia il movimento
        splineQ = false; // Assicurati che la spline di grado 4 sia disattivata
        moving4 = false; // Assicurati che il movimento della spline di grado 4 sia fermo
    }
} else if (key == 'q' || key == 'Q') {
    //spline di grado 4
    if (splineQ) {
        splineQ = false;
        moving4 = false;
    } else {
        splineQ = true;
        tParam4 = 0; // Reset del parametro temporale
        moving4 = true; // Avvia il movimento
        spline = false; // Assicurati che la spline di grado 3 sia disattivata
        moving = false; // Assicurati che il movimento della spline di grado 3 sia fermo
    }
}
  
  else if (key == 'h' || key == 'H') {
    // Se è la prima volta che si preme il tasto "h" o è stato premuto prima
    if (!keyPressedBefore) {
      // Cambia lo stato della visibilità della grafica
      legendaVisibile = !legendaVisibile;
      keyPressedBefore = true;
    } else {
      // Se il tasto "h" è stato premuto precedentemente, nascondi la grafica
      legendaVisibile = false;
      keyPressedBefore = false;
    }
  }
  
  else if (keyCode == RIGHT && canDrawPolygons) {
    // Termina la creazione del poligono corrente e inizia un nuovo poligono
    if (isFirstPolygon) {
      if (firstPolygon.size() > 0) {
        perimetroP.addAll(createPerimeterLines(firstPolygon));
        isFirstPolygon = false; // Passa ai poligoni successivi
        polygons.add(new ArrayList<PVector>());
      }
    } else {
      if (polygons.get(polygons.size() - 1).size() > 0) {
          perimetroO.addAll(createPerimeterLines(polygons.get(polygons.size() - 1)));
      }
        
    }
      polygons.add(new ArrayList<PVector>());
    } else if (keyCode == ENTER) {
      // Disabilita la possibilità di disegnare nuovi poligoni e nascondi i punti
      canDrawPolygons = false;
      displayPoints = false;
    } 
 
}

void mousePressed() {
  // Controlla se il mouse è all'interno della grafica e se la grafica è visibile
  if (legendaVisibile && mouseX > legendaX && mouseX < legendaX + 300 && mouseY > legendaY && mouseY < legendaY + 400) {
    // Se il mouse è all'interno della grafica, inizia il trascinamento della grafica
    isDragging = true;
    // Calcola l'offset tra la posizione del mouse e la posizione della grafica
    offsetX = legendaX - mouseX;
    offsetY = legendaY - mouseY;
  }
}

void mouseDragged() {
  // Trascina la grafica solo se il trascinamento è attivo e il mouse è all'interno della grafica
  if (isDragging && mouseX > legendaX && mouseX < legendaX + 300 && mouseY > legendaY && mouseY < legendaY + 400) {
    legendaX = mouseX + offsetX;
    legendaY = mouseY + offsetY;
  }
}

void mouseReleased() {
  // Termina il trascinamento della grafica quando il pulsante del mouse viene rilasciato
  isDragging = false;
}


//Classi Linea, Cell, Nodo 
class Linea {
  PVector p1, p2; // Punti di inizio e fine della linea
  
  Linea(PVector p1, PVector p2) {
    this.p1 = p1;
    this.p2 = p2;

  }
  
  float x1, y1, x2, y2; // Coordinate dei punti di inizio e fine della linea
  
  Linea(float x1, float y1, float x2, float y2){
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;

  }
  
 boolean uguale(Linea other, float tolleranza) {
    // Verifica uguaglianza con tolleranza
    return (Math.abs(this.x1 - other.x1) < tolleranza && 
            Math.abs(this.y1 - other.y1) < tolleranza && 
            Math.abs(this.x2 - other.x2) < tolleranza && 
            Math.abs(this.y2 - other.y2) < tolleranza) ||
           (Math.abs(this.x1 - other.x2) < tolleranza && 
            Math.abs(this.y1 - other.y2) < tolleranza && 
            Math.abs(this.x2 - other.x1) < tolleranza && 
            Math.abs(this.y2 - other.y1) < tolleranza);
  }
  
  boolean containsPoint(PVector punto) {
    return (punto.x == x1 && punto.y == y1) || (punto.x == x2 && punto.y == y2);
  }
  
 boolean overlaps(Linea other) {
    // Controlla se due linee si sovrappongono parzialmente
    return ((this.x1 == other.x1 && this.y1 == other.y1) || (this.x1 == other.x2 && this.y1 == other.y2)  || 
            (this.x2 == other.x1 && this.y2 == other.y1) || (this.x2 == other.x2 && this.y2 == other.y2 ));
  }
  
  // Metodo che calcola il punto medio della linea
  PVector puntoMedio() {
    float mx = (this.x1 + this.x2) / 2;
    float my = (this.y1 + this.y2) / 2;
    return new PVector(mx, my);
  }
  
  void display() {
    stroke(#D0E2F0, 230); // Colore verde
    line(x1, y1, x2, y2);
  }
  
  PVector other(Float x, Float y) {
    PVector p2 = new PVector(this.x2, this.y2);
    PVector p1 = new PVector(this.x1, this.y1);
    if (this.x1 == x && this.y1 == y) return p2;
    if (this.x2 == x && this.y2 == y) return p1;
    return null;
  }
  
  float distanceTo(Linea other) {
    float dist1 = distPointToLine(other.x1, other.y1, this);
    float dist2 = distPointToLine(other.x2, other.y2, this);
    float dist3 = distPointToLine(this.x1, this.y1, other);
    float dist4 = distPointToLine(this.x2, this.y2, other);
    
    // Trova la distanza minima tra tutte le distanze calcolate
    float minDistance = min(min(dist1, dist2), min(dist3, dist4));
    
    return minDistance;
  }

  float distPointToLine(float px, float py, Linea line) {
    PVector lineStart = new PVector(line.x1, line.y1);
    PVector lineEnd = new PVector(line.x2, line.y2);
    PVector point = new PVector(px, py);
    PVector lineVec = PVector.sub(lineEnd, lineStart);
    PVector pointVec = PVector.sub(point, lineStart);
    float lineLength = lineVec.mag();
    lineVec.normalize();
    float projection = pointVec.dot(lineVec);
    if (projection < 0) {
      return PVector.dist(point, lineStart);
    } else if (projection > lineLength) {
      return PVector.dist(point, lineEnd);
    } else {
      PVector projectionPoint = PVector.add(lineStart, PVector.mult(lineVec, projection));
      return PVector.dist(point, projectionPoint);
    }
  }
  
  Float lenght(){
    Float xa = this.x1;
    Float ya = this.y1;
    Float xb = this.x2;
    Float yb = this.y2;
    Float square_x = (xa-xb)*(xa-xb);
    Float square_y = (ya-yb)*(ya-yb);
    Float lenght = sqrt(square_x + square_y);
    return lenght; 
  }
  
  
  
}

class Cell {
  PVector vector;
  Linea inizio, fine;
  
  Cell(PVector vector, Linea fine){
    this.vector = vector;
    this.fine = fine;
    this.inizio = null;
  }
  
  Cell(Linea inizio, PVector vector){
    this.vector = vector;
    this.fine = null;
    this.inizio = inizio;
  }
  
  Cell(Linea inizio, Linea fine){ //sono i bordi destro e sinistro di ogni cella
    this.inizio = inizio;
    this.fine = fine;
    this.vector = null;
  }  
  

  
  ArrayList<Linea> getBorders() {
    ArrayList<Linea> borders = new ArrayList<Linea>();
    boolean aggiunto = false;
    boolean trovato = false;
    for(Linea bordo: borders){
      if (inizio != null) {
          if(bordo.x1 == inizio.x1 && bordo.x2 == inizio.x2 && bordo.y1 == inizio.y1 && bordo.y2 == inizio.y2){
            aggiunto = true;
            break;
          }
      }
      if (fine != null) {
          if(bordo.x1 == fine.x1 && bordo.x2 == fine.x2 && bordo.y1 == fine.y1 && bordo.y2 == fine.y2){
            trovato = true;
            break;
          }
      }
    }
    if(!aggiunto){
        borders.add(inizio);
    }
    if(!trovato){
        borders.add(fine);
    }
   
    return borders;
  }
  
  ArrayList<PVector> getMiddles(){
    ArrayList<PVector> middles = new ArrayList<PVector>();
    if(this.vector == null){
      Linea l1 = this.inizio;
      PVector medio1 = l1.puntoMedio();
      Linea l2 = this.fine;
      PVector medio2 = l2.puntoMedio();
      
      boolean aggiunto = false;
      for(PVector p : middles){
        if(p.x == medio1.x && p.y == medio1.y && p.x == medio2.x && p.y == medio2.y){
          aggiunto = true;
          break;
        }
      }
      if(!aggiunto){
        middles.add(medio1);
        middles.add(medio2);
      }
    }

    return middles;
  }
  
  PVector getCenter() {
    if (vector == null) {
      // Assuming Linea inizio and fine are the left and right borders of the cell
      float centerX = (inizio.x1 + inizio.x2 + fine.x1 + fine.x2) / 4;
      float centerY = (inizio.y1 + inizio.y2 + fine.y1 + fine.y2) / 4;
      return new PVector(centerX, centerY);
    } else if (inizio != null) {
      // Caso in cui abbiamo un triangolo (inizio + vector)
      float centerX = (inizio.x1 + inizio.x2 + vector.x) / 3;
      float centerY = (inizio.y1 + inizio.y2 + vector.y) / 3;
      return new PVector(centerX, centerY);
    } else if (fine != null) {
      // Caso in cui abbiamo un triangolo (fine + vector)
      float centerX = (fine.x1 + fine.x2 + vector.x) / 3;
      float centerY = (fine.y1 + fine.y2 + vector.y) / 3;
      return new PVector(centerX, centerY);
    }
    return null; 
  }
  
  boolean isAdjacent(Cell other) {
    if (this.inizio != null && other.inizio != null && (this.inizio.x1 == other.inizio.x1 && this.inizio.y1 == other.inizio.y1 && this.inizio.x2 == other.inizio.x2 && this.inizio.y2 == other.inizio.y2)) return true;
    if (this.fine != null && other.fine != null && (this.fine.x1 == other.fine.x1 && this.fine.y1 == other.fine.y1 && this.fine.x2 == other.fine.x2 && this.fine.y2 == other.fine.y2)) return true;
    if (this.fine != null && other.inizio != null && this.fine.overlaps(other.inizio)) return true;
    if (this.inizio != null && other.fine != null && this.inizio.overlaps(other.fine)) return true;
    if (this.vector != null) {
      if (this.inizio != null && ((other.inizio != null && this.inizio.uguale(other.inizio, 0.0001)) || 
                                  (other.fine != null && this.inizio.uguale(other.fine, 0.0001)))) return true;
      if (this.fine != null && ((other.inizio != null && this.fine.uguale(other.inizio, 0.0001)) || 
                                (other.fine != null && this.fine.uguale(other.fine, 0.0001)))) return true;
    }
    return false;
  }
  
  // Check if a point lies on a line segment
  boolean isPointOnLine(PVector p, Linea l) {
    float crossProduct = (p.y - l.y1) * (l.x2 - l.x1) - (p.x - l.x1) * (l.y2 - l.y1);
    if (Math.abs(crossProduct) > 1e-6) return false;

    float dotProduct = (p.x - l.x1) * (l.x2 - l.x1) + (p.y - l.y1) * (l.y2 - l.y1);
    if (dotProduct < 0) return false;

    float squaredLength = (l.x2 - l.x1) * (l.x2 - l.x1) + (l.y2 - l.y1) * (l.y2 - l.y1);
    if (dotProduct > squaredLength) return false;

    return true;
  }

  // Check if a point lies inside a triangle defined by three points
  boolean isPointInTriangle(PVector p, PVector p1, PVector p2, PVector p3) {

      float d1 = sign(p, p1, p2);
      float d2 = sign(p, p2, p3);
      float d3 = sign(p, p3, p1);
  
      boolean hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
      boolean hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
      
  
      return !(hasNeg && hasPos);
  }

  float sign(PVector p1, PVector p2, PVector p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
  }
  
  boolean isPointInQuadrilateral(PVector p, PVector p1, PVector p2, PVector p3, PVector p4) {
    if(isPointInTriangle(p, p1, p2, p3)){
      return true;
    }
    else if(isPointInTriangle(p, p2, p3, p4)){
      return true;
    }
    return false;
}

  boolean containsPoint(PVector punto) {
    if (vector == null) {
     
      if(isPointInQuadrilateral(punto, new PVector(inizio.x1, inizio.y1), new PVector(inizio.x2, inizio.y2), new PVector(fine.x1, fine.y1), new PVector(fine.x2, fine.y2))){
        return true;
      }
    } else if (inizio != null) {
      
      // Case where we have a triangle (inizio + vector)
      return isPointInTriangle(punto, new PVector(inizio.x1, inizio.y1), new PVector(inizio.x2, inizio.y2), vector);
    } else if (fine != null) {
     
      // Case where we have a triangle (fine + vector)
      return isPointInTriangle(punto, new PVector(fine.x1, fine.y1), new PVector(fine.x2, fine.y2), vector);
    }
   
    return false;
  }
  
  PVector getCommonBorderMidpoint(Nodo nodo) {
    if (nodo == null || nodo.cella == null) {
      return null;
    }

    ArrayList<Linea> thisBorders = this.getBorders();
    ArrayList<Linea> otherBorders = nodo.cella.getBorders();

    if (thisBorders == null || otherBorders == null) {
      return null;
    }

    for (Linea l1 : thisBorders) {
      if (l1 == null) continue;

      for (Linea l2 : otherBorders) {
        if (l2 == null) continue;

        if (l1.overlaps(l2)) {
          Linea commonBorder = getCommonPortion(l1, l2);
          if (commonBorder != null) {
            return commonBorder.puntoMedio();
          }
        }
      }
    }

    return null;
  }

  Linea getCommonPortion(Linea l1, Linea l2) {
    // Determina il segmento di sovrapposizione tra l1 e l2
    float startX = Math.max(l1.x1, l2.x1);
    float startY = Math.max(l1.y1, l2.y1);
    float endX = Math.min(l1.x2, l2.x2);
    float endY = Math.min(l1.y2, l2.y2);

    if (startX <= endX && startY <= endY) {
      return new Linea(startX, startY, endX, endY);
    } else {
      return null;
    }
  }


  
  String printCell(){
    if (vector != null) {
      return "Cell with vector: " + vector;
    } else if (inizio != null && fine != null) {
      return "Cell with inizio: (" + inizio.x1 + ", " + inizio.y1 + ") to (" + inizio.x2 + ", " + inizio.y2 + ")" +
             " and fine: (" + fine.x1 + ", " + fine.y1 + ") to (" + fine.x2 + ", " + fine.y2 + ")";
    } else if (inizio != null) {
      return "Cell with inizio: (" + inizio.x1 + ", " + inizio.y1 + ") to (" + inizio.x2 + ", " + inizio.y2 + ")";
    } else if (fine != null) {
      return "Cell with fine: (" + fine.x1 + ", " + fine.y1 + ") to (" + fine.x2 + ", " + fine.y2 + ")";
    }
    return "Cell with no borders or vectors";
  }  
}

class Nodo {
  Cell cella;
  PVector punto;
  ArrayList<Nodo> vicini;
  ArrayList<Linea> archi;
  

  Nodo(Cell cella, PVector punto) {
    this.cella = cella;
    this.vicini = new ArrayList<Nodo>();
    this.punto = punto;
    this.archi = new ArrayList<Linea>();
  }
  
  Nodo(PVector punto, ArrayList<Linea> archi) {
    //this.cella = cella;
    this.vicini = new ArrayList<Nodo>();
    this.punto = punto;
    this.archi = archi;
  }

  void addVicino(Nodo vicino) {
    boolean aggiunto = false;
    for(Nodo n: vicini){
      if(n.punto.x == vicino.punto.x && n.punto.y == vicino.punto.y){
        aggiunto = true;
        break;
      }
    }
    if(!aggiunto){
      vicini.add(vicino);
    }
  }
  
   PVector getCommonBorderMidpoint(Nodo other) {
    Linea commonBorder = null;

    Linea thisLine1 = this.cella != null ? this.cella.inizio : null;
    Linea thisLine2 = this.cella != null ? this.cella.fine : null;
    Linea otherLine1 = other.cella != null ? other.cella.inizio : null;
    Linea otherLine2 = other.cella != null ? other.cella.fine : null;

    if (thisLine1 != null && otherLine1 != null && thisLine1.overlaps(otherLine1)) {
      commonBorder = getCommonPortion(thisLine1, otherLine1);
    } else if (thisLine2 != null && otherLine2 != null && thisLine2.overlaps(otherLine2)) {
      commonBorder = getCommonPortion(thisLine2, otherLine2);
    } else if (thisLine1 != null && otherLine2 != null && thisLine1.overlaps(otherLine2)) {
      commonBorder = getCommonPortion(thisLine1, otherLine2);
    } else if (thisLine2 != null && otherLine1 != null && thisLine2.overlaps(otherLine1)) {
      commonBorder = getCommonPortion(thisLine2, otherLine1);
    }

    if (commonBorder != null) {
      PVector mid = commonBorder.puntoMedio();
      
      return mid;
    }

    return null;
  }

  Linea getCommonPortion(Linea l1, Linea l2) {
    // Determine the overlap segment between l1 and l2
    float startX = Math.max(l1.x1, l2.x1);
    float startY = Math.max(l1.y1, l2.y1);
    float endX = Math.min(l1.x2, l2.x2);
    float endY = Math.min(l1.y2, l2.y2);
    
    if (startX <= endX && startY <= endY) {
      return new Linea(startX, startY, endX, endY);
    } else {
      return null;
    }
  }
  
}

Cell getCellByCenter(PVector center) {
  for (Cell cell : celle) {
    if (cell.getCenter().x == center.x && cell.getCenter().y == center.y) {
      return cell;
    }
  }
  return null;
}

// Function to get a cell by a point inside it
Cell getCellByPoint(PVector punto, ArrayList<Cell> celle) {
  
  for (Cell cell : celle) {
   
    if (cell.containsPoint(punto)) {
    
      return cell;
    }
  }
  
  return null;
}

Nodo getNodeByCell(Cell cell, ArrayList<Nodo> nodi) {
  for (Nodo nodo : nodi) {
    if (nodo.cella.equals(cell)) {
      return nodo;
    }
  }
  return null;
}

class NodoConDistanza implements Comparable<NodoConDistanza> {
  Nodo nodo;
  float distanza;

  NodoConDistanza(Nodo nodo, float distanza) {
    this.nodo = nodo;
    this.distanza = distanza;
  }

  @Override
  public int compareTo(NodoConDistanza altro) {
    return Float.compare(this.distanza, altro.distanza);
  }
  
   @Override
    public String toString() {
        return "Nodo: " + nodo.punto + ", Distanza: " + distanza;
    }
}





void scorrimento(){
// Disegna la prima barra verticale solo se moveBar1 è true
    if (vel > 0) {
       stroke(0, 0, 255);
      line(barraX, 0, barraX, height);
      
      // Muovi la prima barra verso destra
      barraX += vel;
      
      // Controlla se la prima barra è arrivata al margine destro della scena
      if (barraX >= width) {
        vel = 0; // Ferma il movimento della prima barra
      }
      
      // Controlla se la prima barra interseca un vertice
      for (PVector v : listaOrdinata) {
        if (abs(barraX - v.x) < 2) {
          boolean trovato = false;
          for(int i=0; i<intersectionPoints.size(); i++){
            if( v.x == intersectionPoints.get(i)){
              trovato = true;
              break;
            }
          }
          if(!trovato){
            intersectionPoints.add(v.x); // Aggiungi il punto di intersezione alla lista
  
          }
          
        }
      }
    }
    
    // Disegna le barre verticali nei punti di intersezione e aggiungile alla lista
    stroke(0, 0, 255);
    for (Float x : intersectionPoints) {
      line(x, 0, x, height);
      boolean trovato = false;
      for (Linea linea : verticali) {
        if (linea.x1 == x) {
          trovato = true;
          break;
        }
      }
      if (!trovato) {
         line(x, 0, x, height);
         verticali.add(new Linea(x, 0, x, height));
      }
    }

}



void strutturaGrafo(){
// Disegna le linee verticali e i segmenti verdi solo se fillVerticalLines è true
  if (fillVerticalLines) {
    // Disegna le linee verticali per il primo poligono
    stroke(0, 0, 255); // Colore blu per le linee verticali
    for (PVector v : firstPolygon) {
      Linea verticale = new Linea(v.x, 0, v.x, height);
      line(v.x, 0, v.x, height);
      boolean trovato = false;
      for(Linea vert : verticali){
        if(verticale.x1 == vert.x1 && verticale.y1 == vert.y1 && verticale.x2 == vert.x2 && verticale.y2 == vert.y2){
          trovato = true;
          break;
        }
      }
      if(!trovato){
        verticali.add(verticale);
      }
    }

    // Disegna le linee verticali per tutti gli altri poligoni
    for (ArrayList<PVector> vertices : polygons) {
      for (PVector v : vertices) {
        Linea verticale = new Linea(v.x, 0, v.x, height);
        line(v.x, 0, v.x, height);
        boolean trovato = false;
        for(Linea vert : verticali){
          if(verticale.x1 == vert.x1 && verticale.y1 == vert.y1 && verticale.x2 == vert.x2 && verticale.y2 == vert.y2){
            trovato = true;
            break;
          }
        }
        if(!trovato){
          verticali.add(verticale);
        }
      }
    }
    

    lineSegments.clear();

    // Verifica intersezioni con gli altri poligoni
    for (ArrayList<PVector> vertices : polygons) {
      if (vertices.size() > 2) {
        for (PVector v : vertices) {
          ArrayList<Linea> result = findVerticalLineInsidePolygons(v.x, polygons);
          for(Linea elem : result){
            boolean trovato = false;
            for(Linea line : lineSegments){
              if(elem.x1 == line.x1 && elem.y1 == line.y1 && elem.x2 == line.x2 && elem.y2 == line.y2){
                trovato = true;
                break;
              }
            }
            if(!trovato){
              lineSegments.add(elem);
            }
          }
          
        }
      }
    }
    
    //Elimina occorrenze da lineSegments
    for (int i = 0; i < lineSegments.size(); i++) {
      Linea current = lineSegments.get(i);
        if (current.x1 == current.x2 && current.y1 == current.y2) {
          lineSegments.remove(i);
          i--; // Decrementa j poiché la lista si è ridotta
        }
    }
    
    for(int i = 0; i<lineSegments.size(); i++){
      Linea linea = lineSegments.get(i);
      PVector contains = contienePunto(linea, polygons);
      if(contains != null){
        Float x1 = linea.x1;
        Float y1 = linea.y1;
        Float x2 = linea.x2;
        Float y2 = linea.y2;
        Linea line1 = new Linea(x1, y1, contains.x, contains.y);
        Linea line2 = new Linea(contains.x, contains.y, x2, y2);
       
        
        boolean trovato1 = false;
        boolean trovato2 = false;
        for(Linea l : lineSegments){
          if(l.x1 == line1.x1 && l.y1==line1.y1 && l.x2 == line1.x2 && l.y2==line1.y2){
            trovato1 = true;
            break;
          }
          if(l.x1 == line2.x1 && l.y1==line2.y1 && l.x2 == line2.x2 && l.y2==line2.y2){
            trovato2 = true;
            break;
          }
        }
        if(!trovato1){
          lineSegments.add(line1);
        }
        if(!trovato2){
          lineSegments.add(line2);
        }
        
        //rimuovi line da lineSegments
        lineSegments.remove(linea);
        i--;
      }
    }
  
 
    // Disegna i segmenti
    for (Linea linea : lineSegments) {
     
      linea.display();
    }
    
    //trova i punti di intersezione di verticali con le linee dei poligoni e degli ostacoli: in corrispondenza disegnaci un pallino minuscolo
    for(Linea verticale: verticali){
      ArrayList<PVector> intersezioni = trovaIntersezioni(verticale, perimetroP, perimetroO);
      
      for(PVector v : intersezioni){
        boolean trovato = false;
        for(PVector elem : verticiTot){
          if(v.x == elem.x && v.y == elem.y){
            trovato = true;
            break;
          }
        }
        if(!trovato){
          verticiTot.add(v);
        }
      }
    }
    
    for(PVector v : listaOrdinata){
      boolean trovato = false;
      for(PVector elem : verticiTot){
        if(v.x == elem.x && v.y == elem.y){
          trovato = true;
          break;
        }
      }
      if(!trovato){
        verticiTot.add(v);
      }
    }
    
    //qui devo fare i segmenti
    verticiTot = mergeSortX(verticiTot);
    //raggruppa per ascissa vertTempTot
    // Iterazione attraverso i punti e raggruppamento per ascissa
    for (PVector punto : verticiTot) {
      float ascissa = punto.x;
      // Verifica se l'ascissa è già stata aggiunta a ascisseUniche
      if (!ascisseUniche.contains(ascissa)) {
        // Se l'ascissa non esiste, creiamo una nuova lista per questa ascissa
        ArrayList<PVector> nuovaLista = new ArrayList<PVector>();
        nuovaLista.add(punto);
        vertTot.add(nuovaLista);
        ascisseUniche.add(ascissa);
      } else {
        // Se l'ascissa esiste già, controlla se il punto è già stato aggiunto a una lista
        boolean aggiunto = false;
        for (ArrayList<PVector> lista : vertTot) {
          if (lista.get(0).x == ascissa) { // Controlla solo la prima ascissa nella lista
            if (!lista.contains(punto)) { // Se il punto non è già presente nella lista, aggiungilo
              lista.add(punto);
            }
            aggiunto = true;
            break;
          }
        }
        // Se il punto non è stato aggiunto a nessuna lista, crea una nuova lista
        if (!aggiunto) {
          ArrayList<PVector> nuovaLista = new ArrayList<PVector>();
          nuovaLista.add(punto);
          vertTot.add(nuovaLista);
        }
      }
    }
    
    //ordino la lista per ordinata crescente
    for (int i = 0; i < vertTot.size(); i++) {
      vertTot.set(i, mergeSortY(vertTot.get(i)));
    }

     //calcolo i segmenti corrispondenti.
    for(int i = 0; i<vertTot.size()-1; i++){ //scorro le liste interne di vertTot
      ArrayList<PVector> lista = vertTot.get(i);
      //caso in cui devo distinguere i pezzi dentro agli ostacoli
      for (int j = 0; j < lista.size() - 1; j ++) {
        PVector punto1 = lista.get(j);
        PVector punto2 = lista.get(j + 1);


        line(punto1.x, punto1.y, punto2.x, punto2.y);
    
        // Crea il segmento
        // Aggiungi il segmento alla lista se non esiste già
        boolean trovato = false;
        for (Linea segm : segmenti) {
          if ((segm.x1 == punto1.x && segm.y1 == punto1.y && segm.x2 == punto2.x && segm.y2 == punto2.y) ||
              (segm.x1 == punto2.x && segm.y1 == punto2.y && segm.x2 == punto1.x && segm.y2 == punto1.y)) {
            trovato = true;
            break;
          }
        }
        if (!trovato) {
          segmenti.add(new Linea(punto1.x, punto1.y, punto2.x, punto2.y));
        }
      }
    }
    
   
    
    segmenti = removeLines(segmenti, lineSegments);
    
    //Qui voglio eliminare dall'array di segmenti, tutti i segmenti che hanno per entrambi gli estremi vertici che non appartengono a listaOrdinata
    for(int i = segmenti.size() -1; i >= 0; i--){
      Linea l = segmenti.get(i);
      boolean startContenuto = false;
      boolean endContenuto = false;
      for(PVector v: listaOrdinata){
        if(v.x == l.x1 && v.y == l.y1){
          startContenuto = true;
        }
        if(v.x == l.x2 && v.y == l.y2){
          endContenuto = true;
        }
        if(startContenuto && endContenuto){
          break;
        }
      }
      if(!startContenuto && !endContenuto){
        segmenti.remove(i);
      }
    }
    
    
    
    
    
    //da concavita voglio eliminare i punti tali da avere un segmento con estremo quel punto !!!!
    if(!concavita.isEmpty()){
      for(int i = 0; i< concavita.size(); i++){
        PVector c = concavita.get(i);
        for(Linea segm : segmenti){
          PVector s = new PVector(segm.x1, segm.y1);
          PVector e = new PVector(segm.x2, segm.y2);
          if(((c.x == s.x && c.y == s.y) ||(c.x == e.x && c.y == e.y)) && segm.lenght()!=0){
            
            concavita.remove(c);
        
            i--;
          }
        }
      }
     
      
      
      //qui voglio aggiungere a segmenti, i segmenti costituiti dai punti di concavita
      for(int i = 0; i< concavita.size(); i++){
        PVector p = concavita.get(i);
        Linea l = new Linea(p.x, p.y, p.x, p.y);
        
        //aggiungo a segmenti
        boolean trovato = false;
        for(Linea s : segmenti){
          if(s.x1 == l.x1 && s.y1==l.y1 && s.x2 == l.x2 && s.y2==l.y2){
            trovato = true;
            break;
          }
        }
        if(!trovato){
          segmenti.add(l);
        }
      }
    
    }
    
    
    
    rimanente = trovaPunto(polygons);
    for(int i = 0; i< rimanente.size();i++){
      PVector current = rimanente.get(i);
      Linea l = new Linea(current.x, current.y, current.x, current.y);
      boolean trovato = false;
      for(Linea s: segmenti){
        if(s.x1 == l.x1 && s.y1==l.y1 && s.x2 == l.x2 && s.y2==l.y2){
          trovato = true;
          break;
        }
      }
      if(!trovato){
        segmenti.add(l);
      }
  
    }
    
    
    
    segmenti = bubbleSort(segmenti);
    
    // Disegna i segmenti rimanenti colorati di blu
    for (Linea linea : segmenti) {
      stroke(0, 0, 255); // Colore blu
     
      line(linea.x1, linea.y1, linea.x2, linea.y2);
    }
    
  }
}


void costruzioneGrafoPratico(){
  nodes.clear();
  nodiCammino.clear();
  celle.clear();
  
  //costruisco la lista di tutti i segmenti che devo inserire: 
  //1. il primo lato di perimetroP 
  //2. l'ultimo i lati in mezzo
  //3. l'ultimo lato di perimetroP
  
 
  Linea ultima = null;
  Linea primaTemp = null;
  Linea prima = null;
  
  if (!perimetroP.isEmpty()) {
    ultima = perimetroP.get(0);
    primaTemp = perimetroP.get(0);
  
    for (Linea linea : perimetroP) {
      PVector puntoMedio = linea.puntoMedio();
      float x = puntoMedio.x;
  
      if (x > ultima.puntoMedio().x) {
        ultima = linea;
      }
      if (x < primaTemp.puntoMedio().x) {
        primaTemp = linea;
      }
    }  
   
  
    
    PVector uno = new PVector(primaTemp.x2, primaTemp.y2);
    PVector due = new PVector(primaTemp.x1, primaTemp.y1);
    prima = new Linea (uno.x, uno.y, due.x, due.y);
    
    
    PVector middleP = prima.puntoMedio();
    Float lenP = prima.lenght();
    primoNodo = middleP;
    boolean trovatoP = false;
    for(PVector p : middlePoints){
      if(p.x == middleP.x && p.y == middleP.y){
        trovatoP = true;
        break;
      }
    }
    if(!trovatoP){
      middlePoints.add(middleP);
      segmentsTot.add(prima);
      lenLinea.add(lenP);
    }
    
    
  
    PVector middleU = ultima.puntoMedio();
    ultimoNodo = middleU;
    
    Float lenU = ultima.lenght();
    
    boolean trovatoU = false;
    for(PVector p : middlePoints){
      if(p.x == middleU.x && p.y == middleU.y){
        trovatoU = true;
        break;
      }
    }
    if(!trovatoU){
      middlePoints.add(middleU);
      segmentsTot.add(ultima);
      lenLinea.add(lenU);
    }
  
  }
  
  //se |segmento.y1-segmento.y2| < 3.5 -> rimuovi segmento dalla lista
  for(int i = 0; i < segmenti.size(); i++){
    Linea segm = segmenti.get(i);
    float y1 = segm.y1;
    float y2 = segm.y2;
    
    if(abs(y1-y2) < 3.5 && abs(y1-y2) > 0){
        segmenti.remove(segm);
        i--;
    }
    
  }
  
  for(Linea segm : segmenti){
    PVector middle = segm.puntoMedio();
    Float len = segm.lenght();
    boolean aggiunto= false;
    for(PVector p: middlePoints){
      if(middle.x == p.x && middle.y == p.y){
        aggiunto=true;
        break;
      }
    }
    if(!aggiunto){
      lenLinea.add(len);
      segmentsTot.add(segm);
      middlePoints.add(middle);
    }
  }
  
  
  
  //costruisco le celle
  //1. prendo ultima e prima e costruisco le celle esterne
  //2. prendo i punti di concavita, e costruisco la cella concava
  //3. prendo i punti di rimanenti e costruisco la cella tra due figure
  //4. prendo tutti i punti intermedi
  
  //1. prendo ultima e prima e costruisco le celle esterne
  //1a. prendo i punti di middle che non sono in concavita e in rimanenti e che hanno la x subito maggiore di prima: se sono due allora prendo il segmento totale

  if(!middlePoints.isEmpty()){
    // Inizializza i valori minimi e massimi
    float min1 = Float.MAX_VALUE;
    float min2 = Float.MAX_VALUE;
    float max1 = -Float.MAX_VALUE;
    float max2 = -Float.MAX_VALUE;

    
    for(int i = 0; i<middlePoints.size(); i++){
      float x = middlePoints.get(i).x;
      
      boolean skip = false;
      if(!concavita.isEmpty()){
        for(PVector c : concavita){
          if(c.x == x && c.y == middlePoints.get(i).y){
            skip = true;
            break;
          }
        }
      }
      if(!rimanente.isEmpty()){
        for(PVector r : rimanente){
          if(r.x == x && r.y == middlePoints.get(i).y){
            skip = true;
            break;
          }
        }
      }
      
      if (skip) continue;
      //Trova i due valori minimi
        if (x < min1) {
            min2 = min1;
            min1 = x;
        } else if (x < min2 && x != min1) {
            min2 = x;
        }

        // Trova i due valori massimi
        if (x > max1) {
            max2 = max1;
            max1 = x;
        } else if (x > max2 && x != max1) {
            max2 = x;
        }
    }
    
    
    // ArrayList per memorizzare i punti con il secondo minore e il secondo maggiore x
    ArrayList<PVector> secondMinXPoints = new ArrayList<PVector>();
    ArrayList<PVector> secondMaxXPoints = new ArrayList<PVector>();
    
    ArrayList<Integer> secondMinIndices = new ArrayList<Integer>();
    ArrayList<Integer> secondMaxIndices = new ArrayList<Integer>();

    // Trova i punti con x uguale a min2 e max2
    for (int i = 0; i < middlePoints.size(); i++) {
        PVector p = middlePoints.get(i);
        if (p.x == min2) {
            secondMinXPoints.add(p);
            secondMinIndices.add(i);
        }
        if (p.x == max2) {
            secondMaxXPoints.add(p);
            secondMaxIndices.add(i);
        }
    }
    
  

    if(ultima != null && prima != null){
      float lenf1 = 0;
      float len01 = 0;
      ArrayList<Float> len02 = new  ArrayList<Float>();
      ArrayList<Float> lenf2 = new  ArrayList<Float>();
      for(int i = 0; i< lenLinea.size();i++){
        
        //prima cella
        if(secondMinXPoints.size()==1){
          
          
          for(int elem : secondMinIndices){
            if(i == elem){
              len01 = lenLinea.get(i);
              
            }
          }
        }
        
        if(secondMinXPoints.size() == 2){
          for(int elem : secondMinIndices){
            if(i == elem){
             len02.add(lenLinea.get(i));
            }
          }
        }
        
        //ultima cella 
        if(secondMaxXPoints.size()==1){
          
          for(int elem : secondMaxIndices){
            if(i == elem){
              lenf1 = lenLinea.get(i);
              
            }
          }
        }
        
        if(secondMaxXPoints.size() == 2){
          for(int elem : secondMaxIndices){
            if(i == elem){
             lenf2.add(lenLinea.get(i));
            }
          }
        }
        
      }
      
      // prima cella
      if(secondMinXPoints.size() == 1){
        
        for(PVector p : secondMinXPoints){
          Linea l = lineFromMiddle(p, len01);
          
          PVector m = prima.puntoMedio();
          Linea len = new Linea(m.x, m.y, p.x, p.y);
          PVector primo = new PVector(prima.x2, prima.y2);
          Cell cella0 = new Cell(primo, l);
          
          boolean trovato = false;
          for(Cell cella : celle){
            if(cella.inizio == null){
              if(cella.vector.x == cella0.vector.x && cella.vector.y == cella0.vector.y && cella.fine.x1 == cella0.fine.x1 && cella.fine.y1 == cella0.fine.y1 && cella.fine.x2 == cella0.fine.x2 && cella.fine.y2 == cella0.fine.y2){
                      trovato = true;
                      break;
              }
            }
          }
          if(!trovato){
            celle.add(cella0);
          }
          
          boolean aggiunto = false;
          for(Linea a: archiDaPrimo){
            if(a.x1 == len.x1 && a.y1 == len.y1 && a.x2 == len.x2 && a.y2 == len.y2){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            archiDaPrimo.add(len);
          }
        }
      }
      if(secondMinXPoints.size()==2){
        Linea l1 = lineFromMiddle(secondMinXPoints.get(0), len02.get(0));
        Linea l2 = lineFromMiddle(secondMinXPoints.get(1), len02.get(1));
        Linea l = new Linea(l1.x1, l1.y1, l2.x2, l2.y2);
        
        PVector m = prima.puntoMedio();
        Linea riga1 = new Linea(m.x, m.y, secondMinXPoints.get(0).x, secondMinXPoints.get(0).y);
        Linea riga2 = new Linea(m.x, m.y, secondMinXPoints.get(1).x, secondMinXPoints.get(1).y);

        PVector primo = new PVector(prima.x2, prima.y2);
        Cell cella0 = new Cell(primo, l);
     
        boolean trovato = false;
        for(Cell cella : celle){
          if(cella.inizio == null){
              if(cella.vector.x == cella0.vector.x && cella.vector.y == cella0.vector.y && cella.fine.x1 == cella0.fine.x1 && cella.fine.y1 == cella0.fine.y1 && cella.fine.x2 == cella0.fine.x2 && cella.fine.y2 == cella0.fine.y2){
                      trovato = true;
                      break;
              }
            }
        }
        if(!trovato){
          celle.add(cella0);       
        }
        
        boolean aggiunto = false;
          for(Linea a: archiDaPrimo){
            if((a.x1 == riga1.x1 && a.y1 == riga1.y1 && a.x2 == riga1.x2 && a.y2 == riga1.y2) && (a.x1 == riga2.x1 && a.y1 == riga2.y1 && a.x2 == riga2.x2 && a.y2 == riga2.y2)){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            archiDaPrimo.add(riga1);
            archiDaPrimo.add(riga2);
          }
        
      }
      
      
       // ultima
      
       if(secondMaxXPoints.size() == 1){
        
        for(PVector p : secondMaxXPoints){
          
          PVector m = ultima.puntoMedio();
          Linea riga = new Linea(m.x, m.y, p.x, p.y);
          
          Linea l = lineFromMiddle(p, lenf1);
          PVector ultimo = new PVector(ultima.x2, ultima.y2);
          Cell cellaf = new Cell(l, ultimo);
          boolean trovato = false;
          for(Cell cella : celle){
            if(cella.fine == null){
              if(cella.vector.x == cellaf.vector.x && cella.vector.y == cellaf.vector.y && cella.inizio.x1 == cellaf.inizio.x1 && cella.inizio.y1 == cellaf.inizio.y1 && cella.inizio.x2 == cellaf.inizio.x2 && cella.inizio.y2 == cellaf.inizio.y2){
                      trovato = true;
                      break;
              }
            }
          }
          if(!trovato){
            celle.add(cellaf);
          }
          
          boolean aggiunto = false;
          for(Linea a: archiPerUltimo){
            if(a.x1 == riga.x1 && a.y1 == riga.y1 && a.x2 == riga.x2 && a.y2 == riga.y2){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            archiPerUltimo.add(riga);
          }
        }
      }
      if(secondMaxXPoints.size()==2){
        Linea l1 = lineFromMiddle(secondMaxXPoints.get(0), lenf2.get(0));
        Linea l2 = lineFromMiddle(secondMaxXPoints.get(1), lenf2.get(1));
        Linea l = new Linea(l1.x1, l1.y1, l2.x2, l2.y2);
        
        PVector m = ultima.puntoMedio();
        Linea riga1 = new Linea(secondMaxXPoints.get(0).x, secondMaxXPoints.get(0).y, m.x, m.y);
        Linea riga2 = new Linea(secondMaxXPoints.get(1).x, secondMaxXPoints.get(1).y, m.x, m.y);
        
        PVector ultimo = new PVector(ultima.x2, ultima.y2);
        Cell cellaf = new Cell(l, ultimo);
        boolean trovato = false;
        for(Cell cella : celle){
          if(cella.fine == null){
              if(cella.vector.x == cellaf.vector.x && cella.vector.y == cellaf.vector.y && cella.inizio.x1 == cellaf.inizio.x1 && cella.inizio.y1 == cellaf.inizio.y1 && cella.inizio.x2 == cellaf.inizio.x2 && cella.inizio.y2 == cellaf.inizio.y2){
                      trovato = true;
                      break;
              }
            }
        }
        if(!trovato){
            celle.add(cellaf);
          }
          
          boolean aggiunto = false;
          for(Linea a: archiPerUltimo){
            if((a.x1 == riga1.x1 && a.y1 == riga1.y1 && a.x2 == riga1.x2 && a.y2 == riga1.y2) && (a.x1 == riga2.x1 && a.y1 == riga2.y1 && a.x2 == riga2.x2 && a.y2 == riga2.y2)){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            archiPerUltimo.add(riga1);
            archiPerUltimo.add(riga2);
          }
      }  
    }
    
    //celle nel mezzo
    for(int i = 2; i < middlePoints.size()-1; i++){
      ArrayList<Linea> adiac = new ArrayList<Linea>();
      ArrayList<PVector> punti = new ArrayList<PVector>();
      ArrayList<Float> lunghezze = new ArrayList<Float>();
      //calcolo i segmenti che congiungono il punto medio i-esimo a tutti gli altri, prendo i punti medi dei segmenti che non hanno intersezioni con gli ostacoli
      //verifico che abbiano la stessa x e allora costruisco la cella che li unisce 
      PVector current = middlePoints.get(i);
      for(int j = i+1; j < middlePoints.size(); j++){
        PVector successor = middlePoints.get(j);
        //calcolo il segmento che va da current a tutti gli altri punti medi, che serve per verificare se ci sono intersezioni con gli ostacoli
        Linea riga = new Linea(current.x, current.y, successor.x, successor.y);
        if(!perimetroO.isEmpty() ){
          ArrayList<PVector> intOstacoli = intersezioniLinee(perimetroO, riga);
          if(intOstacoli.size() == 0 ){
            if(!segmentsTot.isEmpty() && !lenLinea.isEmpty()){
              ArrayList<PVector> intersezione = calcolaIntersezioni(current, successor, segmentsTot);
              if(intersezione.size()==2){
                for(PVector t: intersezione){
                  if(t.x == successor.x && t.y == successor.y){
                    //aggiungo il punto alla lista dei punti
                    boolean trovato= false;
                    for(PVector p:punti){
                      if(p.x == t.x && p.y == t.y){
                        trovato = true;
                        break;
                      }
                    }
                    if(!trovato){
                      lunghezze.add(lenLinea.get(j));
                      punti.add(t);
                      archi.add(riga);
                    }
                  }
                }
                
              }
            }
          } 
        }
      }
      
      // per ogni riga ho qui una lista di adiacenze
      if(!punti.isEmpty() && !lunghezze.isEmpty()){
    
        for(int h = 0; h<punti.size(); h++){
          Linea l = lineFromMiddle(punti.get(h), lunghezze.get(h));

          
          boolean trovato = false;
          for(Linea a: adiac){
            if(a.x1 == l.x1 && a.y1 == l.y1 && a.x2 == l.x2 && a.y2 == l.y2){
              trovato = true;
              break;
            }
          }
          if(!trovato){
            adiac.add(l);
          }
        }
      }
      
      if(!adiac.isEmpty()){
        if(adiac.size() == 1){
          for(Linea l: adiac){
            Linea line = lineFromMiddle(current, lenLinea.get(i));
            Cell cella = new Cell(line, l);
            
            boolean aggiunta = false;
            for(Cell c: celle){
              if(c.vector == null && c.inizio != null && c.fine != null){
                if(c.inizio.x1 == cella.inizio.x1 && c.inizio.y1 == cella.inizio.y1 && c.inizio.x2 == cella.inizio.x2 && c.inizio.y2 == cella.inizio.y2 && c.fine.x1 == cella.fine.x1 && c.fine.y1 == cella.fine.y1 && c.fine.x2 == cella.fine.x2 && c.fine.y2 == cella.fine.y2 ){
                  aggiunta = true;
                  break;
                }
              }
            }
            if(!aggiunta){
              celle.add(cella);
            }
          }
          
        }
        
        if(adiac.size()==2){
          Linea l0 = adiac.get(0);
          Linea l1 = adiac.get(1);
          Linea l = new Linea(l0.x1, l0.y1, l1.x2, l1.y2);
          Linea line = lineFromMiddle(current, lenLinea.get(i));
          Cell cella = new Cell(line, l);
          
          boolean aggiunta = false;
          for(Cell c: celle){
            if(c.vector == null && c.inizio != null && c.fine != null){
              if(c.inizio.x1 == cella.inizio.x1 && c.inizio.y1 == cella.inizio.y1 && c.inizio.x2 == cella.inizio.x2 && c.inizio.y2 == cella.inizio.y2 && c.fine.x1 == cella.fine.x1 && c.fine.y1 == cella.fine.y1 && c.fine.x2 == cella.fine.x2 && c.fine.y2 == cella.fine.y2 ){
                aggiunta = true;
                break;
              }
            }
          }
          if(!aggiunta){
            celle.add(cella);
          }
        }
      }
      
    }
    
    
    if(!celle.isEmpty()){
    
      for (int i = 0; i < celle.size() - 1; i++) {
          Cell cella1 = celle.get(i);
  
          for (int j = i + 1; j < celle.size(); j++) {
              Cell cella2 = celle.get(j);
              if (cella1.vector == null && cella2.vector == null && cella1.fine != null && cella2.fine != null) {
                  if (cella1.fine.x1 == cella2.fine.x1 && cella1.fine.y1 == cella2.fine.y1 && cella1.fine.x2 == cella2.fine.x2 && cella1.fine.y2 == cella2.fine.y2) {
                      Linea inizio1 = cella1.inizio;
                      Linea inizio2 = cella2.inizio;
                      Linea inizio = new Linea(inizio1.x1, inizio1.y1, inizio2.x2, inizio2.y2);
                      Cell cell = new Cell(inizio, cella1.fine);
  
                      boolean trovato = false;
                      for (Cell cella : celle) {
                          if (cella.fine != null && cella.inizio != null) {
                              if (cella.fine.x1 == cell.fine.x1 && cella.fine.y1 == cell.fine.y1 && cella.fine.x2 == cell.fine.x2 && cella.fine.y2 == cell.fine.y2 &&
                                  cella.inizio.x1 == cell.inizio.x1 && cella.inizio.y1 == cell.inizio.y1 && cella.inizio.x2 == cell.inizio.x2 && cella.inizio.y2 == cell.inizio.y2) {
                                  trovato = true;
                                  break;
                              }
                          }
                      }
                      if (!trovato) {  
                          celle.add(cell);
  
                      }
                  }
              }
              if (cella1.vector != null && cella1.fine == null && cella2.fine == null) {
                  if (cella1.vector.x == cella2.vector.x && cella1.vector.y == cella2.vector.y) {
                      Linea inizio1 = cella1.inizio;
                      Linea inizio2 = cella2.inizio;
                      Linea inizio = new Linea(inizio1.x1, inizio1.y1, inizio2.x2, inizio2.y2);
                      Cell cell = new Cell(inizio, cella1.vector);
  
                      boolean trovato = false;
                      for (Cell cella : celle) {
                          if (cell.vector != null && cell.inizio != null) {
                              if (cella.vector.x == cell.vector.x && cella.vector.y == cell.vector.y && cella.inizio.x1 == cell.inizio.x1 && cella.inizio.y1 == cell.inizio.y1 && cella.inizio.x2 == cell.inizio.x2 && cella.inizio.y2 == cell.inizio.y2) {
                                  trovato = true;
                                  break;
                              }
                          }
                      }
                      if (!trovato) {
                          celle.add(cell);
                      }
                  }
              }
          }
      }
      
      for(int i = 0; i<celle.size()-1; i++){
        for(int j = i+1; j<celle.size(); j++){
          Cell cella1 = celle.get(i);
          Cell cella2 = celle.get(j);
          if(cella1.vector == null && cella2.vector == null && cella1.inizio != null && cella2.inizio != null && cella1.fine != null && cella2.fine != null){
            if((abs(cella1.inizio.x2 - cella2.inizio.x1)<0.0001) && (abs(cella1.inizio.y2 - cella2.inizio.y1)<0.0001) && (abs(cella1.fine.x1 - cella2.fine.x1) < 0.0001) && (abs(cella1.fine.y1 - cella2.fine.y1) < 0.0001) && (abs(cella1.fine.x2 - cella2.fine.x2) < 0.0001) && (abs(cella1.fine.y2 - cella2.fine.y2)<0.0001)){
              celle.remove(cella1);
              j--;
              celle.remove(cella2);
              j--;
            }
          }
          if(cella1.vector != null && cella2.vector != null && cella1.inizio != null && cella2.inizio != null && cella1.fine == null && cella2.fine == null){
            if((abs(cella1.inizio.x2 - cella2.inizio.x1)< 0.0001) && (abs(cella1.inizio.y2 - cella2.inizio.y1)<0.0001) && (abs(cella1.vector.x - cella2.vector.x)<0.0001) && (abs(cella1.vector.y - cella2.vector.y)<0.0001)){
              celle.remove(cella1);
              j--;
              celle.remove(cella2);
              j--;
              
            }
          }
        }
      }
      
      
      if(!concavita.isEmpty()){
        for(PVector c: concavita){
       
          boolean aggiunto = false;
          for(PVector s: puntiSpecial){
            if(c.x == s.x && c.y == s.y){
              aggiunto=true;
              break;
            }
          }
          if(!aggiunto){
            puntiSpecial.add(c);
          }
        }
      }
      
      if(!rimanente.isEmpty()){
        for(PVector r: rimanente){
          boolean aggiunto = false;
          for(PVector s: puntiSpecial){
            if(r.x == s.x && r.y == s.y){
              aggiunto=true;
              break;
            }
          }
          if(!aggiunto){
            puntiSpecial.add(r);
          }
        }
      }
      
      
      if(!puntiSpecial.isEmpty() && !middlePoints.isEmpty() && !segmentsTot.isEmpty() && !perimetroO.isEmpty() && !lenLinea.isEmpty()){

        for(int i=0; i<middlePoints.size(); i++){
          PVector p = middlePoints.get(i);
          
          for(PVector c: puntiSpecial){
          
            if(p.x != c.x && p.y != c.y){
              Linea riga = new Linea(c.x, c.y, p.x, p.y);
              
              ArrayList<PVector> inters = calcolaIntersezioni(c, p, segmentsTot);
              ArrayList<PVector> crash = intersezioniLinee(perimetroO, riga);
             
              if(inters.size()==1 && crash.size()==1){
                  PVector elem = inters.get(0);
                  
                  if(elem.x != c.x && elem.y != c.y){
                    Linea l = lineFromMiddle(elem, lenLinea.get(i));
                    if(c.x < elem.x){
                      
                      PVector punto = new PVector(l.x1, l.y1);
                      Linea l1 = new Linea(punto.x, punto.y, c.x, c.y);
                      Cell cella = new Cell(l1, l);
                      boolean aggiunto=false;
                      for(Cell cl: celle){
                        
                        if(cella.fine != null && cella.inizio == null && cl.inizio == null){
                          if(cl.vector.x == cella.vector.x && cl.vector.y == cella.vector.y && cella.fine.x1 == cl.fine.x1 && cella.fine.y1 == cl.fine.y1 && cella.fine.x2 == cl.fine.x2 && cella.fine.y2 == cl.fine.y2){
                            aggiunto=true;
                            break;
                          }
                        }
                      }
                      if(!aggiunto){
                        celle.add(cella);
                      }
                      
                    }
                    if(c.x > elem.x){
                      Cell cella = new Cell(l, c);
                      
                      boolean aggiunto=false;
                      for(Cell cl: celle){
                        
                        if(cella.inizio != null && cella.fine == null && cl.fine == null){
                          PVector s = cella.inizio.puntoMedio();
                          PVector e = cella.vector;
                          Linea ll = new Linea(s.x, s.y, e.x, e.y);
                          boolean trovato = false;
                          for(Linea a : archi){
                            if(ll.x1 == a.x1 && ll.y1 == a.y1 && ll.x2 == a.x2 && ll.y2 == a.y2){
                              trovato = true;
                              break;
                            }
                          }
                          if(!trovato){
                            archi.add(ll);
                          }
                          if(cl.vector.x == cella.vector.x && cl.vector.y == cella.vector.y && cl.inizio.x1 == cella.inizio.x1 && cl.inizio.y1 == cella.inizio.y1 && cl.inizio.x2 == cella.inizio.x2 && cl.inizio.y2 == cella.inizio.y2){
                            aggiunto = true;
                            break;
                          }
                        }
                      }
                      if(!aggiunto){
                        celle.add(cella);
                        
                      }

                    }

                  }
                
                
              }
            }
          }
        }
      }
      
      
      // Trova il centro di ogni cella e disegna un pallino
    for (Cell cell : celle) {
      PVector center = cell.getCenter();
      Nodo nodo = new Nodo(cell, center);

      
      boolean aggiunto = false;
      for(Nodo nodi: nodes){
        if(nodi.punto.x == center.x && nodi.punto.y == center.y){
          aggiunto = true;
          break;
        }
      }
      if(!aggiunto){
        nodes.add(nodo);
      }
    }
    
    
     if(!nodes.isEmpty()){
      // Connessione dei nodi adiacenti
      for (int i = 0; i < nodes.size(); i++) {
        for (int j = i + 1; j < nodes.size(); j++) {
          Cell cell1 = getCellByCenter(nodes.get(i).punto);
          Cell cell2 = getCellByCenter(nodes.get(j).punto);
          if (cell1 != null && cell2 != null && cell1.isAdjacent(cell2)) {
            nodes.get(i).addVicino(nodes.get(j));
            nodes.get(j).addVicino(nodes.get(i));
          }
        }
  
            Nodo concavo = nodes.get(nodes.size()-1);
            PVector p = concavo.punto;
            
            if(nodes.get(i).punto.x == p.x && nodes.get(i).punto.y == p.y) {
             
              if(nodes.get(i).vicini.size() != 1){
               
                for(Nodo v : nodes.get(i).vicini){
                  PVector vic = v.punto;
                  
                  ArrayList<PVector> inters = calcolaIntersezioni(p, vic, segmenti);
                  if(inters.size()==0){
                    
                    for(int z = 0; z < concavo.vicini.size(); z++){
                      Nodo vicino = concavo.vicini.get(z);
                       
                      if(vicino.punto.x == vic.x && vicino.punto.y == vic.y){
                        
                        concavo.vicini.remove(z);
                        z--;
                      }
                      for(int h = 0; h < vicino.vicini.size(); h++){
                        Nodo straVicino = vicino.vicini.get(h);
                        if(straVicino.punto.x == p.x && straVicino.punto.y == p.y){
                          vicino.vicini.remove(h);
                          h--;
                        }
                      }
                    }
                  }
                 
              
                }
              }
            }
          
        
      }
      
     }
    } 
  
  }

}

void grafoVero(){
  if(!middlePoints.isEmpty() && !archi.isEmpty()){

    if(!archiDaPrimo.isEmpty() && archiDaPrimo.size()>1 && primoNodo != null){

      ArrayList<Linea> archiTemp = new ArrayList<Linea>();
      if(archiDaPrimo.size()==2){
        Linea elem = archiDaPrimo.get(1);
        boolean ok = false;
        for(Linea l: archiTemp){
          if(l.x1 == elem.x1 && l.y1 == elem.y1 && l.x2==elem.x2 && l.y2 == elem.y2){
            ok = true;
            break;
          }
        }
        if(!ok){
          archiTemp.add(elem);
        }
        
        Nodo primo = new Nodo(primoNodo, archiTemp);
        boolean aggiunto = false;
        for(Nodo n: nodiCammino){
          if(n.punto.x == primo.punto.x && n.punto.y == primo.punto.y){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          nodiCammino.add(primo);
        }
      }
      
      if(archiDaPrimo.size()>2){
        Linea elem1 = archiDaPrimo.get(1);
        Linea elem2 = archiDaPrimo.get(2);
        
        boolean ok = false;
        for(Linea l: archiTemp){
          if((l.x1 == elem1.x1 && l.y1 == elem1.y1 && l.x2==elem1.x2 && l.y2 == elem1.y2) || (l.x1 == elem2.x1 && l.y1 == elem2.y1 && l.x2==elem2.x2 && l.y2 == elem2.y2)){
            ok = true;
            break;
          }
        }
        if(!ok){
          archiTemp.add(elem1);
          archiTemp.add(elem2);
          
          
        }
        
        Nodo primo = new Nodo(primoNodo, archiTemp);
        boolean aggiunto = false;
        for(Nodo n: nodiCammino){
          if(n.punto.x == primo.punto.x && n.punto.y == primo.punto.y){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          nodiCammino.add(primo);
        }
        
      }

    }
   
    for(int i = 2; i < middlePoints.size(); i++){
      PVector m = middlePoints.get(i);
     
      ArrayList<Linea> archiPerNodo = new ArrayList<Linea>();
      
      for(Linea l: archi){
        
        if((l.x1==m.x && l.y1==m.y) || (l.x2==m.x && l.y2==m.y)){
          boolean aggiunto = false;
          for(Linea a: archiPerNodo){
            if((a.x1 == l.x1 && a.y1 == l.y1 && a.x2 == l.x2 && a.y2 == l.y2) || ((a.x1 == l.x2 && a.y1 == l.y2 && a.x2 == l.x1 && a.y2 == l.y1)) ){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
           
            archiPerNodo.add(l);
          }
        }
      }
      Nodo nod = new Nodo(m, archiPerNodo);
      boolean aggiunto = false;
      for(Nodo n: nodiCammino){
        if(n.punto.x == nod.punto.x && n.punto.y == nod.punto.y){
          aggiunto = true;
          break;
        }
      }
      if(!aggiunto){
        nodiCammino.add(nod);
      } 
    }
    
    
    if(!archiPerUltimo.isEmpty() && archiPerUltimo.size()>1 && ultimoNodo != null){
     
      ArrayList<Linea> archiTemp = new ArrayList<Linea>();
      if(archiPerUltimo.size()==2){
        Linea elem = archiPerUltimo.get(1);
        boolean ok = false;
        for(Linea l: archiTemp){
          if(l.x1 == elem.x1 && l.y1 == elem.y1 && l.x2==elem.x2 && l.y2 == elem.y2){
            ok = true;
            break;
          }
        }
        if(!ok){
          archiTemp.add(archiPerUltimo.get(1));
        }
        
        Nodo ultimo = new Nodo(ultimoNodo, archiTemp);
        boolean aggiunto = false;
        for(Nodo n: nodiCammino){
          if(n.punto.x == ultimo.punto.x && n.punto.y == ultimo.punto.y){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          nodiCammino.add(ultimo);
        }
      }
      
      if(archiPerUltimo.size()>2){
        Linea elem1 = archiPerUltimo.get(1);
        Linea elem2 = archiPerUltimo.get(2);
        
        boolean ok = false;
        for(Linea l: archiTemp){
          if((l.x1 == elem1.x1 && l.y1 == elem1.y1 && l.x2==elem1.x2 && l.y2 == elem1.y2) || (l.x1 == elem2.x1 && l.y1 == elem2.y1 && l.x2==elem2.x2 && l.y2 == elem2.y2)){
            ok = true;
            break;
          }
        }
        if(!ok){
          archiTemp.add(elem1);
          archiTemp.add(elem2);
          
          
        }
        
        Nodo ultimo = new Nodo(ultimoNodo, archiTemp);
        boolean aggiunto = false;
        for(Nodo n: nodiCammino){
          if(n.punto.x == ultimo.punto.x && n.punto.y == ultimo.punto.y){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          nodiCammino.add(ultimo);
        }
      }
    
    }
    
    for(int i = 0; i < nodiCammino.size(); i++){
      Nodo current = nodiCammino.get(i);
      
      for(int j = 0; j<nodiCammino.size(); j++){
       Nodo other = nodiCammino.get(j);
       for(Linea a: current.archi){
         for(Linea b: other.archi){
           if((a.x1 == b.x1 && a.y1 == b.y1 && a.x2 == b.x2 && a.y2 == b.y2) || (a.x1 == b.x2 && a.y1 == b.y2 && a.x2 == b.x1 && a.y2 == b.y1)){
             current.addVicino(other);
           }
         }
       }
      }
      if(current.punto.x == primoNodo.x && current.punto.y == primoNodo.y){
        if(current.archi.size()==1){
          Linea arco = current.archi.get(0);
          for(int j=0; j<nodiCammino.size(); j++){
            Nodo other = nodiCammino.get(j);
            if(arco.x2 == other.punto.x && arco.y2 == other.punto.y){
              current.addVicino(other);
              other.addVicino(current);
            }
          }
        }
        
        if(current.archi.size()==2){
          Linea arco1 = current.archi.get(0);
          Linea arco2 = current.archi.get(1);
          for(int j=0; j<nodiCammino.size(); j++){
            Nodo other = nodiCammino.get(j);
            if((arco1.x2 == other.punto.x && arco1.y2 == other.punto.y) || (arco2.x2 == other.punto.x && arco2.y2 == other.punto.y)){
              current.addVicino(other);
              other.addVicino(current);
            }
          }
        }
      }
      
      if(current.punto.x == ultimoNodo.x && current.punto.y == ultimoNodo.y){
        if(current.archi.size()==1){
          Linea arco = current.archi.get(0);
          for(int j=0; j<nodiCammino.size(); j++){
            Nodo other = nodiCammino.get(j);
            if(arco.x2 == other.punto.x && arco.y2 == other.punto.y){
              current.addVicino(other);
              other.addVicino(current);
            }
          }
        }
        
        if(current.archi.size()==2){
          Linea arco1 = current.archi.get(0);
          Linea arco2 = current.archi.get(1);
          for(int j=0; j<nodiCammino.size(); j++){
            Nodo other = nodiCammino.get(j);
            if((arco1.x2 == other.punto.x && arco1.y2 == other.punto.y) || (arco2.x2 == other.punto.x && arco2.y2 == other.punto.y)){
              current.addVicino(other);
              other.addVicino(current);
            }
          }
        }
      }
      
    }
    
  }
}


PVector currentPosition;
void camminoMinimo(){
    if (startingPoint != null && endingPoint != null && !celle.isEmpty()) {
    
    

   
    Cell startCell = null;
    Cell endCell = null;
    Nodo startNode = null;
    Nodo endNode = null;

    try {
     
     
      endCell = getCellByPoint(endingPoint, celle);
      startCell = getCellByPoint(startingPoint, celle);
     
    } catch (NullPointerException e) {
      println("Errore nel trovare le celle: " + e.getMessage());
    }

    try {
      if (startCell != null && endCell != null) {
        
        PVector medioStart = startCell.getCenter();
        startNode = new Nodo(startCell, medioStart);
        PVector medioEnd = endCell.getCenter();
        endNode = new Nodo(endCell, medioEnd);

      }
    } catch (NullPointerException e) {
      println("Errore nel trovare i nodi: " + e.getMessage());
    }

    try {
      if (startNode != null && endNode != null) {
        generatePath(startingPoint, startNode, endNode, endingPoint);
        
        if (!pathPoints.isEmpty()) {
          for (PVector points : pathPoints) {
            currentPosition = points;
           
          }

        // Verifica se pathPoints non è vuoto prima di accedere al primo elemento
        
         
          currentPosition = pathPoints.get(0);
          
        }
        else{
          println(" pathPoints è vuoto");
        }
      }
    } catch (Exception e) {
      println("Errore nella generazione del percorso: " + e.getMessage());
      e.printStackTrace(); 
    }
  }
}


void generatePath(PVector startingPoint, Nodo startingNode, Nodo endingNode, PVector endingPoint) {
  if(startingPoint != null && startingNode != null && endingPoint != null && endingNode != null){
    boolean okstart = false;
  
    for (PVector punto : pathPoints) {
      if (punto.x == startingPoint.x && punto.y == startingPoint.y) {
        okstart = true;
        break;
      }
    }
    if (!okstart) {
      pathPoints.add(startingPoint);
    }
    
    
    //aggiungi i nodi inizio e fine alla lista di nodiCammino e aggiungi ai vicini i punti medi delle linee tra di l
    
    Nodo startNodo = creaNuovoNodo(startingNode);
    
    for(Linea a: startNodo.archi){
      PVector p = new PVector(a.x2, a.y2);
      
      for(Nodo n: nodiCammino){
        if(p.x == n.punto.x && p.y == n.punto.y){
          startNodo.addVicino(n);
          n.addVicino(startNodo);
        }
      }
    }
    
    boolean ok = false;
    for(Nodo n: nodiCammino){
      if(n.punto.x == startNodo.punto.x && n.punto.y == startNodo.punto.y){
        ok=true;
        break;
      }
    }
    if(!ok){
      nodiCammino.add(startNodo);
    }
    
    //endNodo
    Nodo endNodo = creaNuovoNodo(endingNode);
    
    for(Linea a: endNodo.archi){
      PVector p = new PVector(a.x2, a.y2);
      
      for(Nodo n: nodiCammino){
        if(p.x == n.punto.x && p.y == n.punto.y){
          endNodo.addVicino(n);
          n.addVicino(endNodo);
        }
      }
    }
    
    boolean okk = false;
    for(Nodo n: nodiCammino){
      if(n.punto.x == endNodo.punto.x && n.punto.y == endNodo.punto.y){
        okk=true;
        break;
      }
    }
    if(!okk){
      nodiCammino.add(endNodo);
    }

    ArrayList<Nodo> pathNodes = dijkstraPath(startNodo, endNodo, nodiCammino);
    
    if(pathNodes.size()>3){
     
      for(int i=0; i<pathNodes.size(); i++){
        Nodo middle = pathNodes.get(1);
        Nodo tempEnd = pathNodes.get(2);
       
        
        if(!((startNodo.punto.x <= middle.punto.x && middle.punto.x <= tempEnd.punto.x) || (startNodo.punto.x >= middle.punto.x && middle.punto.x >= tempEnd.punto.x))){
          
          for(Nodo n: startNodo.vicini){
            if(n.punto.x == middle.punto.x && n.punto.y==middle.punto.y){
              
              pathNodes.remove(middle);
              i--;
              
            }
            
          }
        }
        
        //end
        Nodo tempStart = pathNodes.get(pathNodes.size()-3);
        Nodo mid = pathNodes.get(pathNodes.size()-2);
        
        if(!((endNodo.punto.x <= mid.punto.x && mid.punto.x <= tempStart.punto.x) || (endNodo.punto.x >= mid.punto.x && mid.punto.x >= tempStart.punto.x))){
          
          for(Nodo n: endNodo.vicini){
            if(n.punto.x == mid.punto.x && n.punto.y==mid.punto.y){
              
              pathNodes.remove(mid);
              i--;
              
            }
           
          }
        }
      }
    }
    
    // Booleano per controllare se abbiamo raggiunto endingPoint
    boolean reachedEndingPoint = false;

      for (int i = 0; i < pathNodes.size(); i++) {
        Nodo nodo = pathNodes.get(i);
    
        // Aggiungi il nodo corrente al percorso se non è già presente
        boolean trovato = false;
        for (PVector punto : pathPoints) {
          if (punto.x == nodo.punto.x && punto.y == nodo.punto.y) {
            trovato = true;
            break;
          }
        }
        if (!trovato) {
          pathPoints.add(nodo.punto);
        }
    
        // Controlla se il nodo corrente è vicino all'endingPoint
        if (nodo.punto.x == endingPoint.x && nodo.punto.y == endingPoint.y) {
          reachedEndingPoint = true;
          boolean aggiunto = false;
          for(PVector vector : pathPoints){
            if(vector.x == endingPoint.x && vector.y == endingPoint.y){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            pathPoints.add(endingPoint); // Aggiungi endingPoint al percorso
            break; // Esci dal ciclo una volta raggiunto endingPoint
          }
        }
      }
    
      // Se non abbiamo ancora aggiunto endingPoint e abbiamo raggiunto endingNode, aggiungilo alla fine
      if (!reachedEndingPoint) {
        boolean okend = false;
        for (PVector punto : pathPoints) {
          if (punto.x == endingPoint.x && punto.y == endingPoint.y) {
            okend = true;
            break;
          }
        }
        if (!okend) {
          pathPoints.add(endingPoint);
        }
      }
      
      
      
      
      for(int i = 0; i<pathPoints.size(); i++){
        PVector current = pathPoints.get(i);
        if((current.x == startNodo.punto.x && current.y == startNodo.punto.y) || (current.x == endNodo.punto.x && current.y == endNodo.punto.y)){
          pathPoints.remove(i);
          i--;
        }
      }

  } 
  
}

//Questa funzione crea un nodo vero a partire dalle coordinate del punto di un nodo teorico 
Nodo creaNuovoNodo(Nodo node){
  ArrayList<Linea> startArchi = new ArrayList<Linea>();
    if(node.cella.vector == null ){
     
      PVector p0 = node.cella.inizio.puntoMedio();
      PVector p1 = node.cella.fine.puntoMedio();
      
      //in middlePoints, quanti hanno la stessa x di p0? Se uno solo ok, altrimenti disegna 2 archi
      ArrayList<PVector> middles = new ArrayList<PVector>();
      for(PVector m: middlePoints){
        if(abs(p0.x - m.x)<0.0001 && abs(p0.y - m.y)<0.0001){
          //!!!
          boolean aggiunto = false;
          for(PVector a: middles){
            if(a.x == m.x && a.y == m.y){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            middles.add(m);
          }
          
          
        }
      }
      if(middles.size()==1){
        Linea arco0 = new Linea(node.punto.x, node.punto.y, middles.get(0).x, middles.get(0).y);

        boolean aggiunto = false;
          for(Linea a: startArchi){
            if(a.x1 == arco0.x1 && a.y1 == arco0.y1 && a.x2 == arco0.x2 && a.y2 == arco0.y2){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            startArchi.add(arco0);
          }
        
        
      }
      if(middles.size()==2){
        PVector m1 = middles.get(0);
        PVector m2 = middles.get(1);
        
        Linea arco00 = new Linea(node.punto.x, node.punto.y, m1.x, m1.y);
        Linea arco01 = new Linea(node.punto.x, node.punto.y, m2.x, m2.y);

        boolean aggiunto = false;
        for(Linea a: startArchi){
          if((a.x1 == arco00.x1 && a.y1 == arco00.y1 && a.x2 == arco00.x2 && a.y2 == arco00.y2) || (a.x1 == arco01.x1 && a.y1 == arco01.y1 && a.x2 == arco01.x2 && a.y2 == arco01.y2)){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          startArchi.add(arco00);
          startArchi.add(arco01);
        }
        
        
      }
      
      
      ArrayList<PVector> middles1 = new ArrayList<PVector>();
      for(PVector m: middlePoints){
        if(abs(p1.x - m.x)<0.0001 && abs(p1.y - m.y)<0.0001){

          boolean aggiunto = false;
          for(PVector a: middles1){
            if(a.x == m.x && a.y == m.y){
              aggiunto = true;
              break;
            }
          }
          if(!aggiunto){
            middles1.add(m);
          }
        }
      }
      if(middles1.size()==1){
        Linea arco1 = new Linea(node.punto.x, node.punto.y, middles1.get(0).x, middles1.get(0).y);
        
        boolean aggiunto = false;
        for(Linea a: startArchi){
          if(a.x1 == arco1.x1 && a.y1 == arco1.y1 && a.x2 == arco1.x2 && a.y2 == arco1.y2){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          startArchi.add(arco1);
        }
      }
      if(middles1.size()==2){
        PVector m1 = middles1.get(0);
        PVector m2 = middles1.get(1);
        
        Linea arco10 = new Linea(node.punto.x, node.punto.y, m1.x, m1.y);
        Linea arco11 = new Linea(node.punto.x, node.punto.y, m2.x, m2.y);
        
        boolean aggiunto = false;
        for(Linea a: startArchi){
          if((a.x1 == arco10.x1 && a.y1 == arco10.y1 && a.x2 == arco10.x2 && a.y2 == arco10.y2) || (a.x1 == arco11.x1 && a.y1 == arco11.y1 && a.x2 == arco11.x2 && a.y2 == arco11.y2)){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          startArchi.add(arco10);
          startArchi.add(arco11);
        }
        
      }
    }
    
    if(node.cella.vector != null){
      if(node.cella.inizio == null){
        
        PVector p = new PVector(node.cella.fine.x1, node.cella.fine.y1);
        Linea newInizio = new Linea(p.x, p.y, node.cella.vector.x, node.cella.vector.y);
        PVector p0 = newInizio.puntoMedio();
        Linea arco0 = new Linea(node.punto.x, node.punto.y, p0.x, p0.y);
        
       
       
        boolean aggiunto = false;
        for(Linea a: startArchi){
          if(a.x1 == arco0.x1 && a.y1 == arco0.y1 && a.x2 == arco0.x2 && a.y2 == arco0.y2){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          startArchi.add(arco0);
        }
        
         PVector p1 = node.cella.fine.puntoMedio();
        ArrayList<PVector> middles1 = new ArrayList<PVector>();
        for(PVector m: middlePoints){
          if(abs(p1.x - m.x)<0.0001 && abs(p1.y - m.y)<0.0001){
            
            boolean trovato = false;
            for(PVector a: middles1){
              if(a.x == m.x && a.y == m.y){
                trovato = true;
                break;
              }
            }
            if(!trovato){
              middles1.add(m);
            }
          }
        }
        if(middles1.size()==1){
          Linea arco1 = new Linea(node.punto.x, node.punto.y, middles1.get(0).x, middles1.get(0).y);

          boolean trovato = false;
          for(Linea a: startArchi){
            if(a.x1 == arco1.x1 && a.y1 == arco1.y1 && a.x2 == arco1.x2 && a.y2 == arco1.y2){
              trovato = true;
              break;
            }
          }
          if(!trovato){
            startArchi.add(arco1);
          }
        }
        if(middles1.size()==2){
          PVector m1 = middles1.get(0);
          PVector m2 = middles1.get(1);
          
          Linea arco10 = new Linea(node.punto.x, node.punto.y, m1.x, m1.y);
          Linea arco11 = new Linea(node.punto.x, node.punto.y, m2.x, m2.y);
          
          boolean trovato = false;
          for(Linea a: startArchi){
            if((a.x1 == arco10.x1 && a.y1 == arco10.y1 && a.x2 == arco10.x2 && a.y2 == arco10.y2) || (a.x1 == arco11.x1 && a.y1 == arco11.y1 && a.x2 == arco11.x2 && a.y2 == arco11.y2)){
              trovato = true;
              break;
            }
          }
          if(!trovato){
            startArchi.add(arco10);
            startArchi.add(arco11);
          }
          
        }
      }
    
      
      if(node.cella.fine == null){
       
        PVector p = new PVector(node.cella.inizio.x1, node.cella.inizio.y1);
        Linea newFine = new Linea(p.x, p.y, node.cella.vector.x, node.cella.vector.y);
        
        PVector p1 = newFine.puntoMedio();
        PVector p0 = node.cella.inizio.puntoMedio();
        
        Linea arco1 = new Linea(node.punto.x, node.punto.y, p1.x, p1.y);

        
        boolean aggiunto = false;
        for(Linea a: startArchi){
          if(a.x1 == arco1.x1 && a.y1 == arco1.y1 && a.x2 == arco1.x2 && a.y2 == arco1.y2){
            aggiunto = true;
            break;
          }
        }
        if(!aggiunto){
          startArchi.add(arco1);
        }
        
        ArrayList<PVector> middles = new ArrayList<PVector>();
        for(PVector m: middlePoints){
          if(abs(p0.x - m.x)<0.0001 && abs(p0.y - m.y)<0.0001){
            //!!!
            boolean trovato = false;
            for(PVector a: middles){
              if(a.x == m.x && a.y == m.y){
                trovato = true;
                break;
              }
            }
            if(!trovato){
              middles.add(m);
            }
            
            
          }
        }
        if(middles.size()==1){
          Linea arco0 = new Linea(node.punto.x, node.punto.y, middles.get(0).x, middles.get(0).y);
          
          boolean trovato = false;
            for(Linea a: startArchi){
              if(a.x1 == arco0.x1 && a.y1 == arco0.y1 && a.x2 == arco0.x2 && a.y2 == arco0.y2){
                trovato = true;
                break;
              }
            }
            if(!trovato){
              startArchi.add(arco0);
            }
          
          
        }
        if(middles.size()==2){
          PVector m1 = middles.get(0);
          PVector m2 = middles.get(1);
          
          Linea arco00 = new Linea(node.punto.x, node.punto.y, m1.x, m1.y);
          Linea arco01 = new Linea(node.punto.x, node.punto.y, m2.x, m2.y);
          
          
          boolean trovato = false;
          for(Linea a: startArchi){
            if((a.x1 == arco00.x1 && a.y1 == arco00.y1 && a.x2 == arco00.x2 && a.y2 == arco00.y2) || (a.x1 == arco01.x1 && a.y1 == arco01.y1 && a.x2 == arco01.x2 && a.y2 == arco01.y2)){
              trovato = true;
              break;
            }
          }
          if(!trovato){
            startArchi.add(arco00);
            startArchi.add(arco01);
          }
          
        }
      } 
    }  
    Nodo nodoo = new Nodo(node.punto, startArchi);
    return nodoo;
}


ArrayList<Nodo> dijkstraPath(Nodo start, Nodo end, ArrayList<Nodo> nodi) {
  int INF = Integer.MAX_VALUE;
  HashMap<Nodo, Integer> dist = new HashMap<Nodo, Integer>();
  HashMap<Nodo, Nodo> prev = new HashMap<Nodo, Nodo>();
  for (Nodo nodo : nodi) {
    dist.put(nodo, INF);
    prev.put(nodo, null);
  }
  dist.put(start, 0);

  PriorityQueue<Nodo> codaPriorita = new PriorityQueue<Nodo>((n1, n2) -> dist.get(n1) - dist.get(n2));
  codaPriorita.add(start);

  while (!codaPriorita.isEmpty()) {
    Nodo u = codaPriorita.poll();
    if (u.equals(end)) {
      break;
    }
    for (Nodo v : u.vicini) {
      PVector p = u.punto;
      Linea l = new Linea(p.x, p.y, v.punto.x, v.punto.y);
      float len = l.lenght();
      int alt = int(dist.get(u) + len);
      if (alt < dist.get(v)) {
        dist.put(v, alt);
        prev.put(v, u);
        codaPriorita.remove(v);
        codaPriorita.add(v);
      }
    }
  }

  ArrayList<Nodo> path = new ArrayList<Nodo>();
  Nodo current = end;
  while (current != null) {
    path.add(current);
    current = prev.get(current);
  }
  reverseArrayList(path);
  return path;
}

void reverseArrayList(ArrayList<Nodo> list) {
  int n = list.size();
  for (int i = 0; i < n / 2; i++) {
    Nodo temp = list.get(i);
    list.set(i, list.get(n - i - 1));
    list.set(n - i - 1, temp);
  }
}


ArrayList<PVector> calcolaIntersezioni(PVector start, PVector end, ArrayList<Linea> linee) {
  ArrayList<PVector> intersezioni = new ArrayList<PVector>();
  
  for (Linea linea : linee) {
    float x1 = start.x, y1 = start.y;
    float x2 = end.x, y2 = end.y;
    float x3 = linea.x1, y3 = linea.y1;
    float x4 = linea.x2, y4 = linea.y2;
  
    float den = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
    if (den == 0) continue; // Segmenti paralleli o coincidenti
  
    float t = ((x1-x3)*(y3-y4) - (y1-y3)*(x3-x4)) / den;
    float u = -((x1-x2)*(y1-y3) - (y1-y2)*(x1-x3)) / den;
  
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      float intersectionX = x1 + t * (x2 - x1);
      float intersectionY = y1 + t * (y2 - y1);
      intersezioni.add(new PVector(intersectionX, intersectionY));
    }
  }
  
  return intersezioni;
}


ArrayList<PVector> intersezioniLinee(ArrayList<Linea> ostacoli, Linea arco){
  ArrayList<PVector> inters = new ArrayList<PVector>();
  int count = 0;
  float x0 = arco.x1;
  float y0 = arco.y1;
  float x1 = arco.x2;
  float y1 = arco.y2;
  for(Linea linea : ostacoli){
    float x2 = linea.x1;
    float y2 = linea.y1;
    float x3 = linea.x2;
    float y3 = linea.y2;
    float denom = (y3 - y2) * (x1 - x0) - (y1 - y0) * (x3 - x2);
        if (denom != 0) {
            float t = ((x2 - x0) * (y3 - y2) - (y2 - y0) * (x3 - x2)) / denom;
            float u = ((x2 - x0) * (y1 - y0) - (y2 - y0) * (x1 - x0)) / denom;
            
            if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
                float x_intersezione = x0 + t * (x1 - x0);
                float y_intersezione = y0 + t * (y1 - y0);
                
                if (isOnSegment(x0, y0, x1, y1, x_intersezione, y_intersezione) &&
                    isOnSegment(x2, y2, x3, y3, x_intersezione, y_intersezione)) {
                    
                    
                      
                    boolean presente = false;
                    for (PVector punto : inters) {
                        if (punto.x == x_intersezione && punto.y == y_intersezione) {
                            presente = true;
                            break;
                        }
                    }

                    if (!presente) {
                        count = count +1;
                        inters.add(new PVector(x_intersezione, y_intersezione));
                    }
                }
            }
        }
        
    }
    return inters;
}

// Funzione per verificare se un punto (px, py) è sul segmento di linea (x1, y1) -> (x2, y2): trovata in rete
boolean isOnSegment(float x1, float y1, float x2, float y2, float px, float py) {
  return px >= Math.min(x1, x2) && px <= Math.max(x1, x2) &&
         py >= Math.min(y1, y2) && py <= Math.max(y1, y2);
}

Linea lineFromMiddle(PVector point, Float lenght){ 
    Float x = point.x;
    Float y1 = point.y + lenght/2;
    Float y2 = point.y - lenght/2;
    
    Linea linea = new Linea(x, y2, x, y1);
    return linea;
  }

boolean puntoDiversoDaEstremi(Linea linea, PVector punto) {
  // Verifica se il punto è diverso dagli estremi della linea
  Float x1 = linea.x1;
  Float y1 = linea.y1;
  Float x2 = linea.x2;
  Float y2 = linea.y2;
  return !((punto.x == x1 && punto.y == y1) ||  (punto.x == x2 && punto.y == y2));
}

boolean puntoSullaLinea(Linea linea, PVector punto) {
  // Verifica se il punto appartiene alla linea utilizzando un'approssimazione
  float tolleranza = 0.01; // Tolleranza per l'approssimazione
  float distanzaTotale = dist(linea.x1, linea.y1, linea.x2, linea.y2);
  float distanzaPuntoInizio = dist(linea.x1, linea.y1, punto.x, punto.y);
  float distanzaPuntoFine = dist(linea.x2, linea.y2, punto.x, punto.y);
  return abs(distanzaTotale - (distanzaPuntoInizio + distanzaPuntoFine)) < tolleranza;
}


ArrayList<Linea> removeLines(ArrayList<Linea> segmenti, ArrayList<Linea> lineSegments) {
  ArrayList<Linea> result = new ArrayList<Linea>();
  
  for (Linea linea : segmenti) {
    boolean toRemove = false;
    for (Linea ls : lineSegments) {
      if (distanzaMedia(linea, ls) < 0.01) {
        toRemove = true;
       
        break;
      }
    }
    if (!toRemove) {
      result.add(linea);
    }
  }
  if(result.size()!=lineSegments.size()){
    //la linea in mezzo, passante per il punto concavo va spezzata, ma in lineSegments viene considerata unica
  }
  
  return result;
}

float distanzaMedia(Linea linea1, Linea linea2) {
  // Calcola la distanza euclidea media tra i punti delle due linee
  float distanzaMedia = (distanza(linea1.x1, linea1.y1, linea2.x1, linea2.y1) +
                         distanza(linea1.x2, linea1.y2, linea2.x2, linea2.y2)) / 2;
  return distanzaMedia;
}

float distanza(float x1, float y1, float x2, float y2) {
  // Calcola la distanza euclidea tra due punti
  return sqrt(sq(x2 - x1) + sq(y2 - y1));
}

// Funzione per trovare la porzione di linea verticale dentro tutti i poligoni
ArrayList<Linea> findVerticalLineInsidePolygons(float x, ArrayList<ArrayList<PVector>> polygons) {
  ArrayList<Float> yIntersections = new ArrayList<Float>();
  ArrayList<Linea> segments = new ArrayList<Linea>();

  for (ArrayList<PVector> vertices : polygons) {
    for (int i = 0; i < vertices.size(); i++) {
      PVector v1 = vertices.get(i);
      PVector v2 = vertices.get((i + 1) % vertices.size());
      if ((v1.x < x && v2.x >= x) || (v1.x >= x && v2.x < x)) {
        float y = v1.y + (x - v1.x) * (v2.y - v1.y) / (v2.x - v1.x);
        yIntersections.add(y);
      }
    }
  }
  
  // Ordina le intersezioni per coordinate y
  yIntersections.sort(null);

  // Crea segmenti tra le intersezioni a coppie
  for (int i = 0; i < yIntersections.size() - 1; i += 2) {
    float y1 = yIntersections.get(i);
    float y2 = yIntersections.get(i + 1);
    segments.add(new Linea(x, y1, x, y2));
  }
  
  
  return segments;
}


// Funzione per creare le linee del perimetro di un poligono
ArrayList<Linea> createPerimeterLines(ArrayList<PVector> vertices) {
  ArrayList<Linea> perimeterLines = new ArrayList<Linea>();
  for (int i = 0; i < vertices.size(); i++) {
    PVector start = vertices.get(i);
    PVector end = vertices.get((i + 1) % vertices.size());
    Linea per = new Linea(start.x, start.y, end.x, end.y);
    boolean trovato = false;
    for(Linea line : perimeterLines){
      if(per.x1 == line.x1 && per.y1 == line.y1 && per.x2 == line.x2 && per.y2 == line.y2){
        trovato = true;
        break;
      }
    }
    if(!trovato){
      perimeterLines.add(per);
    }
  }
  return perimeterLines;
}




ArrayList<PVector> trovaIntersezioni(Linea verticale, ArrayList<Linea> perimetroP, ArrayList<Linea> perimetroO) {
  ArrayList<PVector> intersezioni = new ArrayList<PVector>();
  
  // Trova intersezioni con perimetroP
  for (Linea linea : perimetroP) {
    PVector intersezione = calcolaIntersezione(verticale, linea);
    if (intersezione != null) {
      boolean trovato = false;
      for(PVector p : intersezioni){
        if(intersezione.x == p.x && intersezione.y == p.y){
          trovato = true;
          break;
        }
      }
      if(!trovato){
        intersezioni.add(intersezione);
      }
    }
  }
  
  // Trova intersezioni con perimetroO
    for (Linea linea : perimetroO) {
      PVector intersezione = calcolaIntersezione(verticale, linea);
      if (intersezione != null) {
        boolean trovato = false;
        for(PVector p : intersezioni){
          if(intersezione.x == p.x && intersezione.y == p.y){
            trovato = true;
            break;
          }
        }
        if(!trovato){
          intersezioni.add(intersezione);
        }
      }
    }
  
  
  return intersezioni;
}

PVector calcolaIntersezione(Linea verticale, Linea linea) {
  float x = verticale.x1;
  
  if ((linea.x1 < x && linea.x2 > x) || (linea.x1 > x && linea.x2 < x)) {
    float m = (linea.y2 - linea.y1) / (linea.x2 - linea.x1);
    float q = linea.y1 - m * linea.x1;
    float y = m * x + q;
    return new PVector(x, y);
  }
  return null;
}


//funzioni bspline: trovate in rete ad esclusione delle "drawBSpline"
void drawBSpline(ArrayList<PVector> nodes, int resolution) {
  //nodes: insieme di punti di controllo
  //resolution: parametro di risoluzione della curva. Maggiore è la risoluzione, più sono ivalori di t che calcola, più liscia e precisa sarà la curva
  
  if (nodes.size() < 4) {
    // Aggiungi punti intermedi se il numero di punti è inferiore a 4
    while (nodes.size() < 4) {
      for (int i = 0; i < nodes.size() - 1; i++) {
        PVector midPoint = new PVector((nodes.get(i).x + nodes.get(i + 1).x) / 2, 
                                       (nodes.get(i).y + nodes.get(i + 1).y) / 2);
        nodes.add(i + 1, midPoint);
        if (nodes.size() >= 4) break;
      }
    }
  }
  
  noFill(); // Non riempire la forma
  stroke(0); // Colore del bordo nero

  float[] knots = generateKnots(nodes.size(), 3); //crea l'array di nodi necessario per la bspline

  beginShape();
  //per ogni valore di t mappato in un intervallo tra i nodi (esclusi i primi e gli ultimi 3), viene calcolato il punto 
  //corrispondente sulla curva usando de Boor). è proprio il processo che mi porta a non avere una curva spezzata
  for (int i = 0; i <= resolution; i++) {
    float t = map(i, 0, resolution, knots[3], knots[knots.length - 4]); //escludiamo i primi e gli ultimi 3 per evitare di calcolare la curva in regioni in cui non è ben definita o costante
    PVector p = deBoor(nodes, knots, 3, t);
    vertex(p.x, p.y);
  }
  endShape();
}

PVector deBoor(ArrayList<PVector> points, float[] knots, int k, float t) {
  int n = points.size() - 1;
  int d = k; // Grado della B-Spline
  //int m = knots.length - 1;

 // Trova l'indice dello span del nodo
  int span = findKnotSpan(t, knots);

  // Assicurati che lo span sia entro l'intervallo valido
  if (span < d) span = d;
  if (span > n) span = n;

  // Algoritmo di De Boor
  
  //copio i punti di controllo in un array temporaneo
  PVector[] dPoints = new PVector[d + 1];
  for (int j = 0; j <= d; j++) {
    dPoints[j] = points.get(span - d + j).copy();
  }

  //calcolo ricorsivo: si aggiornano iterativamente i punti di controllo, combinando i punti precedenti con un fattore di interpolazione (alpha). Questo viene fatto per ogni livello della ricorsione.
  for (int r = 1; r <= d; r++) {
    for (int j = d; j >= r; j--) {
      float alpha = (t - knots[span - d + j]) / (knots[span + 1 + j - r] - knots[span - d + j]);
      dPoints[j].x = (1 - alpha) * dPoints[j - 1].x + alpha * dPoints[j].x;
      dPoints[j].y = (1 - alpha) * dPoints[j - 1].y + alpha * dPoints[j].y;
    }
  }

  return dPoints[d];
}

int findKnotSpan(float t, float[] knots) {
  int n = knots.length - 1;
  if (t >= knots[n - 3]) return n - 3;
  if (t <= knots[3]) return 3;

  for (int i = 3; i < n - 3; i++) {
    if (t >= knots[i] && t < knots[i + 1]) {
      return i;
    }
  }
  return -1; 
}

//genera i nodi necessari per la spline
float[] generateKnots(int numPoints, int degree) {
  int n = numPoints - 1;
  int m = n + degree + 1; //i primi e gli ultimi sono fissati a valori costanti, mentre quelli intermedi aumentano linearmente
  float[] knots = new float[m + 1];

  for (int i = 0; i <= degree; i++) {
    knots[i] = 0;
  }
  for (int i = degree + 1; i < m - degree; i++) {
    knots[i] = i - degree;
  }
  for (int i = m - degree; i <= m; i++) {
    knots[i] = m - 2 * degree;
  }

  return knots;
}


void drawBSpline4(ArrayList<PVector> nodes, int resolution) {
 // Servono almeno 5 punti per una B-Spline di grado 4
  if (nodes.size() < 5) {
    // Aggiungi punti intermedi se il numero di punti è inferiore a 4
    while (nodes.size() < 5) {
      for (int i = 0; i < nodes.size() - 1; i++) {
        PVector midPoint = new PVector((nodes.get(i).x + nodes.get(i + 1).x) / 2, 
                                       (nodes.get(i).y + nodes.get(i + 1).y) / 2);
        nodes.add(i + 1, midPoint);
        if (nodes.size() >= 5) break;
      }
    }
  }
  
  noFill(); // Non riempire la forma
  stroke(0); // Colore del bordo nero

  int degree = 4; // Grado della B-Spline
  float[] knots = generateKnots4(nodes.size(), degree);

  beginShape();
  for (int i = 0; i <= resolution; i++) {
    float t = map(i, 0, resolution, knots[degree], knots[knots.length - degree - 1]);
    PVector p = deBoor4(nodes, knots, degree, t);
    vertex(p.x, p.y);
  }
  endShape();
}

PVector deBoor4(ArrayList<PVector> points, float[] knots, int k, float t) {
  int n = points.size() - 1;
  int d = k; // Degree of B-Spline
  //int m = knots.length - 1;

  // Find the knot span index
  int span = findKnotSpan4(t, knots);

  // Ensure span is within valid range
  if (span < d) span = d;
  if (span > n) span = n;

  // De Boor's algorithm
  PVector[] dPoints = new PVector[d + 1];
  for (int j = 0; j <= d; j++) {
    dPoints[j] = points.get(span - d + j).copy();
  }

  for (int r = 1; r <= d; r++) {
    for (int j = d; j >= r; j--) {
      float alpha = (t - knots[span - d + j]) / (knots[span + 1 + j - r] - knots[span - d + j]);
      dPoints[j].x = (1 - alpha) * dPoints[j - 1].x + alpha * dPoints[j].x;
      dPoints[j].y = (1 - alpha) * dPoints[j - 1].y + alpha * dPoints[j].y;
    }
  }

  return dPoints[d];
}

int findKnotSpan4(float t, float[] knots) {
  int n = knots.length - 1;
  if (t >= knots[n - 4]) return n - 4;
  if (t <= knots[4]) return 4;

  for (int i = 4; i < n - 4; i++) {
    if (t >= knots[i] && t < knots[i + 1]) {
      return i;
    }
  }
  return -1; // Should not reach here
}

float[] generateKnots4(int numPoints, int degree) {
  int n = numPoints - 1;
  int m = n + degree + 1;
  float[] knots = new float[m + 1];

  for (int i = 0; i <= degree; i++) {
    knots[i] = 0;
  }
  for (int i = degree + 1; i < m - degree; i++) {
    knots[i] = i - degree;
  }
  for (int i = m - degree; i <= m; i++) {
    knots[i] = m - 2 * degree;
  }

  return knots;
}






//algoritmi di ordinamento
ArrayList<PVector> mergeSortX(ArrayList<PVector> listaVertici){
  if (listaVertici.size() <= 1) {
    return listaVertici;
  }
  
  int medio = listaVertici.size() / 2;
  ArrayList<PVector> sinistra = new ArrayList<PVector>(listaVertici.subList(0, medio));
  ArrayList<PVector> destra = new ArrayList<PVector>(listaVertici.subList(medio, listaVertici.size()));
  
  sinistra = mergeSortX(sinistra);
  destra = mergeSortX(destra);
  
 
  return mergeX(sinistra, destra);
}

ArrayList<PVector> mergeX(ArrayList<PVector> sinistra, ArrayList<PVector> destra) {
  ArrayList<PVector> risultato = new ArrayList<PVector>();
  int indiceSinistra = 0;
  int indiceDestra = 0;
  
  while (indiceSinistra < sinistra.size() && indiceDestra < destra.size()) {
    if (sinistra.get(indiceSinistra).x <= destra.get(indiceDestra).x) {
      risultato.add(sinistra.get(indiceSinistra));
      indiceSinistra++;
    } else {
      risultato.add(destra.get(indiceDestra));
      indiceDestra++;
    }
  }
  
  while (indiceSinistra < sinistra.size()) {
    risultato.add(sinistra.get(indiceSinistra));
    indiceSinistra++;
  }
  
  while (indiceDestra < destra.size()) {
    risultato.add(destra.get(indiceDestra));
    indiceDestra++;
  }
  
  return risultato;
}


ArrayList<PVector> mergeSortY(ArrayList<PVector> listaVertici){
  if (listaVertici.size() <= 1) {
    return listaVertici;
  }
  
  int medio = listaVertici.size() / 2;
  ArrayList<PVector> sinistra = new ArrayList<PVector>(listaVertici.subList(0, medio));
  ArrayList<PVector> destra = new ArrayList<PVector>(listaVertici.subList(medio, listaVertici.size()));
  
  sinistra = mergeSortY(sinistra);
  destra = mergeSortY(destra);
  
 
  return mergeY(sinistra, destra);
}

ArrayList<PVector> mergeY(ArrayList<PVector> sinistra, ArrayList<PVector> destra) {
  ArrayList<PVector> risultato = new ArrayList<PVector>();
  int indiceSinistra = 0;
  int indiceDestra = 0;
  
  while (indiceSinistra < sinistra.size() && indiceDestra < destra.size()) {
    if (sinistra.get(indiceSinistra).y <= destra.get(indiceDestra).y) {
      risultato.add(sinistra.get(indiceSinistra));
      indiceSinistra++;
    } else {
      risultato.add(destra.get(indiceDestra));
      indiceDestra++;
    }
  }
  
  while (indiceSinistra < sinistra.size()) {
    risultato.add(sinistra.get(indiceSinistra));
    indiceSinistra++;
  }
  
  while (indiceDestra < destra.size()) {
    risultato.add(destra.get(indiceDestra));
    indiceDestra++;
  }
  
  return risultato;
}

ArrayList<Linea> bubbleSort(ArrayList<Linea> segmenti) {
  int n = segmenti.size();
  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (segmenti.get(j).x1 > segmenti.get(j + 1).x1) {
        // Scambia segmenti.get(j) e segmenti.get(j + 1)
        Linea temp = segmenti.get(j);
        segmenti.set(j, segmenti.get(j + 1));
        segmenti.set(j + 1, temp);
      }
    }
  }
  return segmenti;
}

//Funzioni ausiliarie per intersezioni
// Funzione per verificare se un punto è all'interno di un poligono: utilizza il metodo dell'intersezione di raggi o ray-casting
//conta quante volte una linea orizzontale che passa per il punto (punto) interseca i segmenti del perimetro del poligono (perimetroO). Ogni segmento del poligono è rappresentato da un oggetto Linea.
boolean puntoDentroPoligono(PVector punto, ArrayList<Linea> perimetroO) {
  int numeroIntersezioni = 0;
  
  //Per ogni segmento del perimetro del poligono, chiama lineaInterseca(punto, l) per verificare se il segmento interseca la linea orizzontale che passa per il punto.
  for (Linea l : perimetroO) {
    if (lineaInterseca(punto, l)) {
      numeroIntersezioni++;
    }
  }
  
  // Se il numero di intersezioni è dispari, il punto è dentro il poligono: un punto dentro un poligono interseca un numero dispari di volte una linea orizzontale che si estende all'infinito, mentre un punto all'esterno interseca un numero pari di volte.
  return (numeroIntersezioni % 2 == 1);
}

boolean lineaInterseca(PVector punto, Linea linea) {
  // Controlla se il segmento del poligono interseca una linea orizzontale che passa per `punto`
  if ((linea.y1 > punto.y) != (linea.y2 > punto.y)) {
    // Calcola l'intersezione della linea orizzontale con il segmento
    float xIntersezione = linea.x1 + (punto.y - linea.y1) * (linea.x2 - linea.x1) / (linea.y2 - linea.y1);
    
    // Verifica se l'intersezione è a destra del punto
    return punto.x < xIntersezione;
  }
  return false;
}


void removePoints(ArrayList<PVector> mainList, ArrayList<PVector> pointsToRemove) {
  // Itera su tutti i punti da rimuovere
  for (PVector p : pointsToRemove) {
    // Rimuove ogni punto dalla lista principale
    mainList.remove(p);
  }
}

// Rimuovi il poligono dall'elenco
void removePolygon(ArrayList<ArrayList<PVector>> polygons, ArrayList<PVector> polygonToRemove) {
  polygons.remove(polygonToRemove);
}

// Funzione per verificare se due poligoni sono sovrapposti e restituire i vertici del poligono con indice maggiore
ArrayList<PVector> getOverlappingPolygon(ArrayList<ArrayList<PVector>> polygons) {
  for (int i = 0; i < polygons.size()-1; i++) {
    for (int j = i + 1; j < polygons.size(); j++) {
      ArrayList<PVector> vertices = polygons.get(j);
      if(vertices.size()>1){
        if (areTwoPolygonsOverlapping(polygons.get(i), polygons.get(j))) {
          // Restituisce i vertici del poligono con indice maggiore
          return polygons.get(j);
        }
      }
    }
    
  }
  return null; // Nessuna sovrapposizione trovata
}

// Funzione per verificare se due poligoni specifici si sovrappongono
boolean areTwoPolygonsOverlapping(ArrayList<PVector> poly1, ArrayList<PVector> poly2) {
  
  // Controlla se un vertice di poly1 è dentro poly2
  for (PVector v : poly1) {
    if (isPointInsidePolygon(v, poly2)) {
      return true;
    }
  }

  // Controlla se un vertice di poly2 è dentro poly1
  for (PVector v : poly2) {
    if (isPointInsidePolygon(v, poly1)) {
      return true;
    }
  }

  // Controlla se i bordi di poly1 intersecano i bordi di poly2
  for (int i = 0; i < poly1.size(); i++) {
    PVector p1 = poly1.get(i);
    PVector p2 = poly1.get((i + 1) % poly1.size());

    for (int j = 0; j < poly2.size(); j++) {
      PVector p3 = poly2.get(j);
      PVector p4 = poly2.get((j + 1) % poly2.size());

      if (doLinesIntersect(p1, p2, p3, p4)) {
        return true;
      }
    }
  }

  return false;
}

// Funzione per verificare se un punto è all'interno di un poligono 
boolean isPointInsidePolygon(PVector point, ArrayList<PVector> polygon) {
  int intersections = 0;
  for (int i = 0; i < polygon.size(); i++) {
    PVector p1 = polygon.get(i);
    PVector p2 = polygon.get((i + 1) % polygon.size());

    if (rayIntersectsSegment(point, p1, p2)) {
      intersections++;
    }
  }
  return (intersections % 2) == 1;
}

// Funzione per verificare se un raggio interseca un segmento di linea: trovata in rete 
boolean rayIntersectsSegment(PVector point, PVector p1, PVector p2) {
  if (p1.y > p2.y) {
    PVector temp = p1;
    p1 = p2;
    p2 = temp;
  }

  if (point.y == p1.y || point.y == p2.y) {
    point.y += 0.0001; // Evita ambiguità
  }

  if (point.y < p1.y || point.y > p2.y) {
    return false; // Punto non all'interno dei limiti y del segmento
  }

  if (point.x >= max(p1.x, p2.x)) {
    return false; // Punto a destra del segmento
  }

  if (point.x < min(p1.x, p2.x)) {
    return true; // Punto a sinistra del segmento
  }

  float m = (p2.y - p1.y) / (p2.x - p1.x); // Pendenza del segmento
  float xIntersection = p1.x + (point.y - p1.y) / m;

  return point.x < xIntersection;
}

// Funzione per verificare se due segmenti si intersecano
boolean doLinesIntersect(PVector p1, PVector p2, PVector p3, PVector p4) {
  float d1 = direction(p3, p4, p1);
  float d2 = direction(p3, p4, p2);
  float d3 = direction(p1, p2, p3);
  float d4 = direction(p1, p2, p4);

  if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
    return true;
  }

  if (d1 == 0 && onSegment(p3, p4, p1)) return true;
  if (d2 == 0 && onSegment(p3, p4, p2)) return true;
  if (d3 == 0 && onSegment(p1, p2, p3)) return true;
  if (d4 == 0 && onSegment(p1, p2, p4)) return true;

  return false;
}

// Funzione di direzione per i segmenti: trovata in rete
float direction(PVector pi, PVector pj, PVector pk) {
  return (pk.x - pi.x) * (pj.y - pi.y) - (pj.x - pi.x) * (pk.y - pi.y);
}



PVector curveIntersectsPerimeter(ArrayList<PVector> points, ArrayList<Linea> perimetroO, int resolution) { //trovata in rete e adattata ai miei scopi e alle mie variabili
    if (points.size() < 4) return null; // Almeno 4 punti sono necessari per una B-Spline

    float[] knots = generateKnots(points.size(), 3);

    PVector lastPoint = deBoor(points, knots, 3, knots[3]);

    for (int i = 1; i <= resolution; i++) {
        float t = map(i, 0, resolution, knots[3], knots[knots.length - 4]);
        PVector currentPoint = deBoor(points, knots, 3, t);

        for (Linea line : perimetroO) {
            PVector intersection = getIntersectionPoint(lastPoint, currentPoint, new PVector(line.x1, line.y1), new PVector(line.x2, line.y2));
            if (intersection != null) {
                return intersection; // Ritorna il primo punto di intersezione trovato
            }
        }

        lastPoint = currentPoint;
    }

    return null; // Nessuna intersezione trovata
}

// Funzione per calcolare il punto di intersezione tra due segmenti di linea: scritta da me a partire dalla formula matematica 
PVector getIntersectionPoint(PVector p1, PVector p2, PVector p3, PVector p4) {
    float denom = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y);

    if (denom == 0) {
        return null; // Le linee sono parallele
    }

    float ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denom;
    float ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denom;

    if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
        // Intersezione trovata
        float x = p1.x + ua * (p2.x - p1.x);
        float y = p1.y + ua * (p2.y - p1.y);
        return new PVector(x, y);
    }

    return null; // Nessuna intersezione
}


boolean segmentsIntersect(PVector p1, PVector p2, PVector p3, PVector p4) { //variante di quella sopra, scritta da me
    float den = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);
    if (den == 0) return false; // I segmenti sono paralleli

    float ua = ((p3.x - p1.x) * (p3.y - p4.y) - (p3.y - p1.y) * (p3.x - p4.x)) / den;
    float ub = ((p3.x - p1.x) * (p1.y - p2.y) - (p3.y - p1.y) * (p1.x - p2.x)) / den;

    return (ua >= 0 && ua <= 1) && (ub >= 0 && ub <= 1);
}


//funzione che verifica se un punto è all'interno di un poligono: trovata in rete
boolean isInsidePolygon(float x, float y, ArrayList<PVector> vertices) { 
  int intersections = 0;
  
  // Linea immaginaria orizzontale che parte dal punto (x, y) e si estende all'infinito verso destra
  PVector extreme = new PVector(width, y);
  
  // Loop attraverso ogni lato del poligono
  for (int i = 0; i < vertices.size(); i++) {
    PVector currentVertex = vertices.get(i);

    PVector nextVertex = vertices.get((i + 1) % vertices.size()); // Il prossimo vertice è l'ultimo vertice se stiamo considerando l'ultimo lato

    // Verifica se la linea immaginaria interseca il lato del poligono
    if (doIntersect(currentVertex, nextVertex, new PVector(x, y), extreme)) {
      // Se l'intersezione è sopra il punto (y), conta l'intersezione
      if (orientation(currentVertex, new PVector(x, y), nextVertex) == 0) {
        return onSegment(currentVertex, new PVector(x, y), nextVertex);
      }
      intersections++;
    }
  }
  
  // Se il numero di intersezioni è dispari, il punto è all'interno del poligono
  return (intersections % 2 != 0);
}

// Verifica se il punto p2 si trova sul segmento formato da p1 e p3: trovata in rete 
boolean onSegment(PVector p1, PVector p2, PVector p3) {
  return (p2.x <= Math.max(p1.x, p3.x) && p2.x >= Math.min(p1.x, p3.x) &&
          p2.y <= Math.max(p1.y, p3.y) && p2.y >= Math.min(p1.y, p3.y));
}

// Determina l'orientazione di una tripletta di punti (p1, p2, p3): trovata in rete
int orientation(PVector p1, PVector p2, PVector p3) {
  float val = (p2.y - p1.y) * (p3.x - p2.x) - (p2.x - p1.x) * (p3.y - p2.y);
  
  if (val == 0) return 0; // I punti sono allineati
  return (val > 0) ? 1 : 2; // Ritorna 1 se l'orientazione è oraria, 2 altrimenti
}

// Verifica se due segmenti si intersecano: scritta da me usando funzioni trovate in rete
boolean doIntersect(PVector p1, PVector q1, PVector p2, PVector q2) {
  int o1 = orientation(p1, q1, p2);
  int o2 = orientation(p1, q1, q2);
  int o3 = orientation(p2, q2, p1);
  int o4 = orientation(p2, q2, q1);
  
  if (o1 != o2 && o3 != o4) return true; // I segmenti si intersecano
  
  if (o1 == 0 && onSegment(p1, p2, q1)) return true; // p1, q1 e p2 sono allineati e p2 si trova sul segmento p1q1
  if (o2 == 0 && onSegment(p1, q2, q1)) return true; // p1, q1 e q2 sono allineati e q2 si trova sul segmento p1q1
  if (o3 == 0 && onSegment(p2, p1, q2)) return true; // p2, q2 e p1 sono allineati e p1 si trova sul segmento p2q2
  if (o4 == 0 && onSegment(p2, q1, q2)) return true; // p2, q2 e q1 sono allineati e q1 si trova sul segmento p2q2
  
  return false; // Non ci sono intersezioni
}


ArrayList<PVector> trovaPunto(ArrayList<ArrayList<PVector>> ll) {
  ArrayList<PVector> countedVectors = new ArrayList<>();
  ArrayList<PVector> result = new ArrayList<>();
  
  for (ArrayList<PVector> innerList : ll) {
    for (PVector vector : innerList) {
      boolean alreadyCounted = false;
      
      // Controlla se il vettore è già stato contato
      for (PVector countedVector : countedVectors) {
        if (isCloseEnough(countedVector, vector, 2)) {
          alreadyCounted = true;
          break;
        }
      }
      
      if (alreadyCounted) {
        // Se è già stato contato, aggiungilo a result solo se non è già presente
        if (!containsCloseEnough(result, vector, 2)) {
          result.add(vector);
        }
      } else {
        // Se non è stato ancora contato, aggiungilo a countedVectors
        countedVectors.add(vector);
      }
    }
  }
  
  // Ritorno dell'ArrayList contenente i vertici con occorrenza maggiore di 1
  return result;
}

// Funzione per verificare se due punti sono abbastanza vicini
boolean isCloseEnough(PVector v1, PVector v2, float tolerance) {
  return v1.dist(v2) <= tolerance;
}

// Funzione per verificare se la lista contiene già un punto abbastanza vicino
boolean containsCloseEnough(ArrayList<PVector> list, PVector vector, float tolerance) {
  for (PVector v : list) {
    if (isCloseEnough(v, vector, tolerance)) {
      return true;
    }
  }
  return false;
}


PVector findConcavityVertex(ArrayList<PVector> vertices) {
  if (vertices.size() < 3) {
    return null; // Un poligono deve avere almeno 3 vertici
  }
  
  int numVertices = vertices.size();
  float lastCrossProduct = 0;
  
  for (int i = 0; i < numVertices; i++) {
    PVector current = vertices.get(i);
    PVector next = vertices.get((i + 1) % numVertices);
    PVector nextNext = vertices.get((i + 2) % numVertices);
    
    PVector edge1 = PVector.sub(next, current);
    PVector edge2 = PVector.sub(nextNext, next);
    
    float crossProduct = edge1.cross(edge2).z;
    
    if (i == 0) {
      lastCrossProduct = crossProduct;
    } else {
      if (lastCrossProduct * crossProduct < 0) {
        return next; // Restituisce il vertice che causa la concavità
      }
    }
    
    lastCrossProduct = crossProduct;
  }

  return null; // Tutti i vertici sono convessi
}



PVector contienePunto(Linea linea, ArrayList<ArrayList<PVector>> polygons) {
  for (ArrayList<PVector> polygon : polygons) {
    for (PVector punto : polygon) {
      if (puntoDiversoDaEstremi(linea, punto) && puntoSullaLinea(linea, punto)) {
        return punto;
      }
    }
  }
  return null;
}
