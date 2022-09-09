# Flows y Validation Rules

## 1. Calculate route.
Dada una ciudad de Origen y otra de Destino, calcula una ruta, si existe y la muestra por pantalla. Si no existe también muestra un mensaje de error al usuario diciendo que no existe una ruta entre ambas ciudades.

- Validation Rule: Different_origin_and_destination. Adicionalmente se creó una Valitation Rule en el objeto Routes, para asegurar que la ciudad de Destino y Origen son  diferentes. Ya que, por ejemplo, no tiene sentido calcular una ruta entre Valencia y Valencia.

## 2. Enter data.
Guía al usuario para automatizar el proceso de entrada de datos. Primeramente, se introduce una ciudad, y luego el usuario tiene la posibilidad de entrar todas las conexiones desde esa ciudad hacia cualquier otra ciudad que exista en el sistema. 

- NOTA: Ambos flows se pueden iniciar desde los dos Utility Items que se encuentran en la esquina inferior izquierda del escritorio.

# Clases de Apex

## 1. calculateRoute
Esta clase contiene todos los métodos necesarios para calcular el camino mínimo entre dos ciudades. Es llamada desde el Flow Calculate Route.

## 2.	Queue 
Salsforce no dispone de una estructura de datos que sea una cola FIFO, la cual es necesaria para hacer BFS en la clase calculateRoute.

# Login URL de la Developer Org

- [Login](https://calibreairlinescom-dev-ed.my.salesforce.com)
