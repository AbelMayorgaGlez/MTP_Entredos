// -*- coding: utf-8; mode: Delphi -*-

program SimulacionEntredos;

{
Diseño propuesto para la realización de la práctica 1 de la asignatura MTP del curso 2010/11
  
  La descripción del problema aparece en la tarea Práctica 1 de la asignatura MTP en el servidor agora.unileon.es
}

const
  NCARTASBARAJAESP = 40; // Número de cartas de la baraja española

  
type
  tNumero = (Uno,Dos,Tres,Cuatro,Cinco,Seis,Siete,Sota,Caballo,Rey);
  tPalo = (Oros,Copas,Espadas,Bastos);
  tIndice = 0..NCARTASBARAJAESP;
  
  // tCarta: Tipo que define las cartas de la baraja española mediante un número y un palo
  tCarta = record
	    numero : tNumero;
	    palo : tPalo;
	    end;
  
  // Operaciones
  function haySalto (c1,c2:tCarta) : boolean;
  { Devuelve true si las cartas c1 y c2 son compatibles para saltar según el solitario Entredos.
    Y lo son cuando son del mismo palo o tienen el mismo número.
  }
    begin
      haySalto := (c1.numero=c2.numero) OR (c1.palo=c2.palo)
    end;
  
type
  // tBaraja: tipo que define una baraja española compuesta de 40 cartas. Tiene que permitir ir sacando
  // cartas hasta que no quede ninguna. También tiene que permitir volver a tener las 40 cartas de nuevo
  //La baraja no está implementada con memoria dinámica debido a que se debe reestablecer su estado, siempre se tendrán las 40 cartas en memoria
  tBaraja = record
	  cartas : array[1..NCARTASBARAJAESP] of tCarta;
	  restantes : tIndice;
	  end;
  // Operaciones
  function crearBaraja : tBaraja;
  { Crea una baraja española con las 40 cartas ordenadas por palos (oros, copas, espadas y bastos)
    y por número del 1 al 7, sota, caballo y rey.
    Fija cuál es la primera carta a sacar y fija el número de cartas que faltan a cuarenta. Fija
    la secuencia de cartas a sacar.
  }
    var
      numero : tNumero;
      palo : tPalo;
      baraja : tBaraja;
      carta : tCarta;
    begin
      baraja.restantes := 0;

      for palo := Oros to Bastos do
	for numero := Uno to Rey do
	  begin
	    carta.numero := numero;
	    carta.palo := palo;
	    baraja.cartas[NCARTASBARAJAESP-baraja.restantes] := carta;
	    baraja.restantes := baraja.restantes + 1;
	  end;

      crearBaraja:=baraja;
    end;

  procedure barajar (var baraja:tBaraja);
  { Procedimiento que desordena las cartas de baraja de forma pseudoaleatoria simulando
    la acción de barajar una baraja española.
    El procedimiento va a ser llamado múltiples veces. Deberí­a ser lo más eficiente posible.
    No cambia la definición de la secuencia de cartas a sacar ni el numero de cartas disponibles.
  }
    var
      cartaAux : tCarta;
      i,Cambio : tIndice;
    begin
      for i := 1 to NCARTASBARAJAESP do
	begin
	  cambio := random(NCARTASBARAJAESP) + 1;
	  cartaAux := baraja.cartas[i];
	  baraja.cartas[i] := baraja.cartas[cambio];
	  baraja.cartas[cambio] := cartaAux;
	end;
    end;

  function sacarCarta (var baraja:tBaraja) : tCarta;
  { Devuelve la carta que corresponde sacar de la baraja, quitándola de la misma.
    Decrece en uno el número de cartas que contiene baraja. La siguiente carta a
    sacar será la siguiente en secuencia a la carta extraida. 
  }
    begin
      sacarCarta := baraja.cartas[baraja.restantes];
      baraja.restantes := baraja.restantes-1;
    end;

  function estaVacia (baraja:tBaraja) : boolean;
  { Devuelve true cuando la baraja ya no tiene cartas que sacar }
    begin
      estaVacia := (baraja.restantes=0);
    end;

  procedure reiniciarBaraja (var baraja:tBaraja);
  { Vuelve la baraja a un estado en el que el la baraja tiene las cuarenta cartas pero posiblemente
    desordenadas, el número de cartas disponibles son cuarenta y la primera carta a sacar
    es la primera de la secuencia de cartas existente previamente.
  }
    begin
      baraja.restantes := 40;
    end;
  
  
type
  pNodo = ^tNodo;
  tNodo = record
      carta : tCarta;
      siguiente : pNodo;
      anterior : pNodo;
      end;

  tPosiciones = 0..NCARTASBARAJAESP;

  // Tipo que permite ir colocándo las cartas de la baraja e ir realizando el solitario entredos
  tMesa = record
      primera : pNodo;
      ultima : pNodo;
      cantidad : tPosiciones;
      end;   

  // Operaciones:
  procedure iniciarMesa (var mesa:tMesa);
  { Inicializa la mesa a vací­a, quitando todas las cartas posibles en ella.
  }
    var
      aux : pNodo;
    begin
      if (mesa.cantidad = 0)
	then begin
	  mesa.primera := NIL;
	  mesa.ultima := NIL;
	  end
	else begin
	  aux := mesa.primera;
	  mesa.ultima := NIL;
	  mesa.cantidad := 0;

	  while (aux<>NIL) do
	    begin
	      mesa.primera := aux^.siguiente;
	      dispose(aux);
	      aux := mesa.primera;
	    end;

	  end;
    end;
  
  procedure ponerCartaEnMesa (carta:tCarta; var mesa: tMesa);
  { Añade la carta en la mesa en la última posición disponible.
  }
    var
      aux : pNodo;
    begin
      new(aux);
      aux^.carta := carta;
      aux^.siguiente := NIL;
      aux^.anterior := mesa.ultima;
      mesa.ultima := aux;

      if (aux^.anterior = NIL)
	then mesa.primera := aux
	else aux^.anterior^.siguiente := aux;

      mesa.cantidad := mesa.cantidad + 1;
    end;
  
  procedure saltoEntredos (var mesa : tMesa; pos : tPosiciones);
  { Realiza un salto entre dos cartas. La pos marca la carta del medio del trio
    de cartas que definen un salto. El resultado del salto es que la carta señalada
    se coloca encima de la carta de su izquierda. 
  }
    var
      aux : pNodo;
      i : tPosiciones;
    begin
      if (pos = 2)
	then begin
	  mesa.primera := mesa.primera^.siguiente;
	  dispose(mesa.primera^.anterior);
	  mesa.primera^.anterior := NIL;
	  end
	else begin
	  aux := mesa.ultima;
	  for i := mesa.cantidad downto pos do aux := aux^.anterior;
	  aux^.anterior^.siguiente := aux^.siguiente;
	  aux^.siguiente^.anterior := aux^.anterior;
	  dispose(aux);
	  end;

      mesa.cantidad:=mesa.cantidad-1;
    end;

  procedure realizarSaltosEntredos (var mesa:tMesa);
  { Realiza todos los saltos entredos posibles según la configuración de entrada de

    mesa. Cambia mesa adecuadamente.
  }
    var
      pos : tPosiciones;
      aux1,aux2 : pNodo;
    begin
      if (mesa.cantidad>=3) //Si hay al menos 3 cartas, puede haber saltos
	then begin
	  // El salto a considerar siempre es el de la última carta con la antepenúltima.
	  aux1 := mesa.ultima;
	  aux2 := aux1^.anterior^.anterior;
	  pos := mesa.cantidad-1;

	  if (haySalto(aux1^.carta,aux2^.carta))
	    then begin
	      saltoEntredos(mesa,pos);
	      // Si se ha producido un salto, quito la última carta y miro a ver si en la nueva mesa hay saltos.
	      mesa.ultima := mesa.ultima^.anterior;
	      mesa.cantidad := mesa.cantidad-1;
	      realizarSaltosEntredos(mesa);
	      // Una vez realizados los saltos de la mesa auxiliar, añado la ultima carta y miro si hay saltos.
	      mesa.ultima := mesa.ultima^.siguiente;
	      mesa.cantidad := mesa.cantidad+1;
	      realizarSaltosEntredos(mesa);
	    end;

	  end;
    end;
						
  
  function haSalidoEntredos (mesa : tMesa) : boolean;
  { Devuelve true si en mesa hay sólo dos cartas y false en otro caso.
  }
    begin
	haSalidoEntredos := (mesa.cantidad = 2);
    end;
  
// Procedimientos y funciones   
  function leerNSimulaciones : longword;
  { Devuelve el número de simulaciones a realizar del solitario entredos. El número
    es obtenido del usuario a través de la entrada estándar.
  }
    var
      seguro : longword; //longword ocupa lo mismo que longint, y en longword todos los valores son positivos
      cad_comprobacion : string;
      codError : integer;
    begin
      seguro := 0;

      repeat
	write('Introduce el número de simulaciones:');
	readln(cad_comprobacion);
	val(cad_comprobacion,seguro,codError);
	if (codError<>0) //Si el codigo de error no es 0, es que lo introducido no se puede guardar en un longword
	  then writeln('Introduce un número mayor que 1')
	  else if(seguro = 0) // No se permiten 0 simulaciones
	    then writeln('Introduce un número mayor que 1');
      until ((codError = 0) AND (seguro<>0));

      leerNSimulaciones := seguro;
    end;
  
  procedure escribirNExitos (nexitos, nsimulaciones: longword);
  { Escribe por salida estándar el porcentaje de éxitos (dado por nexitos) que ha habido en el
    número de simulaciones realizadas (dado por nsimulaciones).
  }
    var
      porcentaje : real;
    begin
      porcentaje := 100*nexitos/nsimulaciones;
      writeln('Porcentaje de aciertos: ',porcentaje:3:2,'%'); // Lo escribe en notación decimal, ocupando 3 espacios y con 2 dígitos decimales.
    end;
  
  
// Variables globales   
var
  nsimulaciones : longword;
  i : longword;
  carta : tCarta;
  baraja : tBaraja;
  mesa : tMesa;
  nexitos : longword;
  
begin
  // Lectura por la entrada estándar del número de simulaciones a realizar del solitario.
  nsimulaciones := leerNSimulaciones();

  // Inicializamos el número de éxitos a 0
  nexitos := 0;
  
  // Creo la baraja inicial
  baraja := crearBaraja();

  randomize;

  // Para cada una de las simulaciones
  for i := 1 to nsimulaciones do
      begin
	//         Barajar la baraja española
	barajar(baraja);
	iniciarMesa(mesa);

	//         Realizar el solitario
	while not estaVacia(baraja) do begin
	    //                       Sacar una carta de la baraja
	    carta := sacarCarta(baraja);

	    //                       Ponerla en la mesa
	    ponerCartaEnMesa(carta,mesa);

	    //                       Realizar los saltos si los hay
	    realizarSaltosEntredos(mesa);
	end;

	// Si el solitario ha finalizado con éxito, aumentar en uno el número de éxitos
	if haSalidoEntredos(mesa) then nexitos := nexitos + 1;
	
	// Volvemos a inicializar baraja
	reiniciarBaraja(baraja);
      end;
  
  // Escritura por la salida estándar del número de éxitos obtenidos divido por el número de simulaciones realizadas.
  escribirNExitos(nexitos,nsimulaciones);
  
end.
