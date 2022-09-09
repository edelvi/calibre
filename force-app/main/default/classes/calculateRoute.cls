public with sharing class calculateRoute {

    @InvocableMethod(label='Get Route' description='Calculate a valid route if exist' )
    public static void calculateRoute(List<Route__c> routes) {
        // Creo el grafo
        Map<City__c, List<Connection__c>> ma = makeMap();

        List<Connection__c> pathSolution = new List<Connection__c>();

        //Para cada ruta que se quiera calcular su camino
        for (Route__c actualRoute : routes) {
            //Obtengo la ciudad de Destino y Origen de la ruta que se quiere calcular
            City__c origin = [SELECT Id, Name FROM City__c WHERE Id =: actualRoute.Origin_City__c LIMIT 1];
            City__c destination = [SELECT Id, Name FROM City__c WHERE Id =: actualRoute.Destination_City__c LIMIT 1];

            //Lista con las respuestas
            List<Connection__c> answer = new List<Connection__c>();

            //Hago BFS para obtener un arbol con la respuesta. Devuelve una lista de conexiones.
            List<Connection__c> bfsPath = bfs(ma, origin, destination, answer);

            // Si hay algun arbol con una solucion
            if(bfsPath!=null){
                //Obtengo el arbol con la solucion final
                pathSolution = pathAnswer(bfsPath);
                //Actualizo las conexiones de la solucion, asignandoles la ruta actual
                assRouteToConnections(pathSolution, actualRoute);
            }

        }
    }

    // Se usa para la creacion del grafo, almacenando para cada ciudad todas sus conexiones.
    private static Map<City__c, List<Connection__c>> makeMap() {
        //En este mapa almaceno para cada ciudad su lista de conexiones
        Map<City__c, List<Connection__c>> graph = new Map<City__c, List<Connection__c>>();

        //Para cada ciudad en la base de datos
        for (City__c city : [select Id, Name from City__c]) {
            //Me detengo en una ciudad, para buscar todas sus conexiones
            City__c actualCity = [SELECT id, Name, (SELECT Id, Name, From_City__c, To_City__c FROM Connections__r ) FROM City__c WHERE Name =: city.Name LIMIT 1];

            //Almaceno todas las conexiones de esa ciudad en una lista de Connection__c 
            List<Connection__c> listConn = new List<Connection__c>();
            for(Connection__c co : actualCity.Connections__r){
                listConn.add(co);
            }

            //Inserto en el mapa la ciudad con su respectiva lista de conexiones
            graph.put(actualCity,listConn);
            
        }        
        return graph;
    }    

    // Se realiza una busqueda en amplitud sobre todo el grafo hasta encontrar a la ciudad de destino.
    private static List<Connection__c> bfs(Map<City__c, List<Connection__c>> graph, City__c startCity, City__c endCity, List<Connection__c> path) {
        // Para guardar si una ciudad ha sido visitada.
        Map<String, Boolean>  status = new Map<String, Boolean>();
        
        // Recorremos todas las ciudades del grafo, y como no las hemos visitado las ponemos en false.
        for (City__c cty : graph.keySet()) {
            status.put(cty.Name, false);
        }

        // Marco como visitada la ciudad de origen
        status.put(startCity.Name, true);

        // Creo una cola para el BFS
        Queue q = new Queue();

        // Pongo en la cola a la ciudad raiz
        q.push(startCity);

        // Mientras que la cola no este vacia
        while (q.size()!=0) {

            // Saco de la cola a la ciudad y la guardo en una variable para saber por que ciudad voy a explorar
            City__c actualCity = (City__c)q.pop();

            // Cojo todas las conexiones para la ciudad actual
            List<Connection__c> connectionsList = [SELECT Id, Name, To_City__c, From_City__c FROM Connection__c WHERE From_City__c =: actualCity.Id ];

            // En este caso no existan un camino con la solucion
            if(connectionsList.isEmpty()==true){
                break;
            }

            // Itero sobre todas las conexiones para la ciudad actual
            for (Connection__c actualConnection : connectionsList) {
                // Cojo el Id de la ciudad destino de la conexion actual
                Id idC = actualConnection.To_City__c;
                
                // Obtengo la ciudad de destino de la conexion en la que me encuentro
                City__c destinationCity = [SELECT Id, Name FROM City__c WHERE Id = :idC LIMIT 1];
                
                // Si la ciudad de destino de la conexion actual es igual a la ciudad Destino, termino
                if(destinationCity.Name == endCity.Name){
                    // Agrego la conexion al path
                    path.add(actualConnection);
                    return path;

                //Si la ciudad de destino no esta visitada, se explora.
                }else if (status.get(destinationCity.Name) == false   ) {
                    //Marcar la ciudad como visitada y la pongo en la cola
                    status.put(destinationCity.Name, true);
                    q.push(destinationCity);

                    // Agrego la conexion al path
                    path.add(actualConnection);
                    
                }
            }
        }
        return null;
    }

    // El metodo bfs devuelve un arbol con la solucion, con este metodo se encuentra el camino del nodo destino a la raiz.
    // Quedando asi una lista con solamente las conxeciones que forman la solucion. La lista quedara ordenada de forma ascendente.
    private static List<Connection__c> pathAnswer(List<Connection__c> path) {
        // Lista donde se almacenara la solucion
        List<Connection__c> solution = new List<Connection__c>();

        // El indice de la ultima conexion, contiene a la ciudad destino, y por lo tanto es la última conexion de la solucion.
        Integer n = path.size()-1;
        
        // Se añade la ultima conexion
        solution.add(path.get(n));

        // Id de la ciudad de Origen(From). Lo necesito para buscar cual de las conexiones del nivel superior la tiene como ciudad Destino
        Id originCityOfConnection = path.get(n).From_City__c;

        // Se decrementa n para seguir moviendonos por las conexiones restantes del arbol
        n--;

        // Itero sobre las conexiones restantes
        for (Integer i = n; i >=0 ; i--) {

            // Si la conexion tiene como Ciudad Destino(To) el id(de la ultima conexion añadida a la solution). Se encontro
            // la conexion en nivel i del arbol.
            if(path.get(i).To_City__c == originCityOfConnection){
                
                // Se agrega la conexion a la solucion
                solution.add(path.get(i));

                // Se actualiza la ciudad de origen, ya que la nueva conexion que se desea encontrar tendra como
                // Ciudad de Origen la de la conexion actual
                originCityOfConnection = path.get(i).From_City__c;                
            }
            
        }
        return solution;        
    }

    // Para que en el Related de Route queden las conexiones que forman la ruta valida.
    // Se logra, asignandole a todas las conexiones el valor de la ruta actual.
    private static void assRouteToConnections(List<Connection__c> answ, Route__c actualRoute) {
        //Lista con las conexiones que se quieren actalizar
        List<Connection__c> connectionsToUpdate = new List<Connection__c>();
        
        // Esta variable la uso para darle un indice con orden a cada conexion
        Integer order = 1;
        Integer n = answ.size()-1;
        for (Integer i = n ; i >=0 ; i--) {
            Connection__c actConnection = answ.get(i);
            //Actualizo el campo Route de cada Conexion, que forma parte de la solucion, con la ruta actual
            actConnection.Route__c = actualRoute.Id;
            
            //Actualizo el campo Route de cada Order_Number, para matener el orden en la solucion, a traves de este indice
            actConnection.Order_Number__c = order++;
            connectionsToUpdate.add(actConnection);
        }
        update connectionsToUpdate;
    }

}